const std = @import("std");

const nvenc_bindings = @import("nvenc_bindings");

const nvenc_log = std.log.scoped(.nvenc_log);

pub const cuda = @import("cuda");

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvenc_bindings.load;

pub const H264Format = enum {
    yuv420,
    yuv444,

    fn to_inner(self: H264Format) nvenc_bindings.BufferFormat {
        return switch (self) {
            .yuv420 => .nv12, // TODO: maybe???
            .yuv444 => .yuv44,
        };
    }
};

pub const H264Profile = enum {
    baseline,
    main,
    high,
    high_444,
    stereo,
    svc_temporal_scalabilty,
    progressive_high,
    constrained_high,
};

pub const HEVCFormat = enum {
    yuv420,
    yuv444,
    yuv420_10bit,
    yuv444_10bit,

    fn to_inner(self: H264Format) nvenc_bindings.BufferFormat {
        return switch (self) {
            .yuv420 => .nv12, // TODO: maybe???
            .yuv444 => .yuv44,
            .yuv420_10bit => .yuv420_10bit,
            .yuv444_10bit => .yuv444_10bit,
        };
    }
};

pub const HEVCProfile = enum {
    main,
    main10,
    frext,
};

/// Codec to use. Choose from H.264 and HEVC (H.265).
/// Note that for each codec you can optionally select a profile. The profile will be forcefully
/// applied to the encoder config. It is recommended to not set it and select a preset. The optimal
/// profile for the selected preset will be used.
pub const Codec = union(enum) {
    h264: struct {
        profile: ?H264Profile,
        format: H264Format,
    },
    hevc: struct {
        profile: ?HEVCProfile,
        format: HEVCFormat,
    },
};

pub const Preset = enum {
    default,
    hp,
    hq,
    bd,
    low_latency_default,
    low_latency_hq,
    low_latency_hp,
    lossless_default,
    lossless_hp,
};

pub const RateControl = union(enum) {
    const_qp: struct {
        inter_p: u32,
        inter_b: u32,
        intra: u32,
    },
    vbr: struct {
        average_bitrate: u32,
        max_bitrate: u32,
    },
    vbr_hq: struct {
        average_bitrate: u32,
        max_bitrate: u32,
    },
    cbr: struct {
        bitrate: u32,
    },
    cbr_hq: struct {
        bitrate: u32,
    },
    cbr_lowdelay_hq: struct {
        bitrate: u32,
    },
};

pub const EncoderOptions = struct {
    codec: Codec,
    preset: Preset = .default,
    resolution: struct {
        width: u32,
        height: u32,
    },
    frame_rate: struct { num: u32, den: u32 } = .{ .num = 30, .den = 1 },
    idr_interval: ?u32 = null,
    rate_control: RateControl = .{ .vbr = .{
        .average_bitrate = 5_000_000,
        .max_bitrate = 10_000_000,
    } },
};

pub const Encoder = struct {
    const IOCacheItem = struct {
        input_registered_resource: nvenc_bindings.RegisteredPtr,
        input_mapped_resource: nvenc_bindings.InputPtr,
        output_bitstream: nvenc_bindings.OutputPtr,
    };

    context: *cuda.Context,
    encoder: ?*anyopaque,
    format: nvenc_bindings.BufferFormat,
    parameter_sets: []u8,

    // The IO cache is needed to keep track of input/output pairs that have
    // been buffered by the encoder. If the encoder produces need_more_input it
    // means more input is needed to produce a frame. In this case we must keep
    // track of the input buffers so we can keep them registered and mapped
    // until we can drain the encoder buffer, which is the next time
    // nvEncEncodePicture returns success.
    io_cache_items: []IOCacheItem,
    io_cache: std.fifo.LinearFifo(IOCacheItem, .Slice),
    draining: bool,

    cur_output_ptr: ?nvenc_bindings.OutputPtr = null,

    allocator: std.mem.Allocator,

    pub fn init(context: *cuda.Context, options: EncoderOptions, allocator: std.mem.Allocator) !Encoder {
        var encoder: ?*anyopaque = null;

        var params = std.mem.zeroes(nvenc_bindings.OpenSessionExParams);
        params.version = nvenc_bindings.open_encode_session_erx_params_ver;
        params.deviceType = .cuda;
        params.device = context.inner;
        params.apiVersion = nvenc_bindings.version;

        try status(nvenc_bindings.nvEncOpenEncodeSessionEx.?(&params, &encoder));

        const codec_guid = switch (options.codec) {
            .h264 => nvenc_bindings.codec_h264_guid,
            .hevc => nvenc_bindings.codec_hevc_guid,
        };

        const preset_guid = switch (options.preset) {
            .default => nvenc_bindings.preset_default_guid,
            .hp => nvenc_bindings.preset_hp_guid,
            .hq => nvenc_bindings.preset_hq_guid,
            .bd => nvenc_bindings.preset_bd_guid,
            .low_latency_default => nvenc_bindings.preset_low_latency_default_guid,
            .low_latency_hq => nvenc_bindings.preset_low_latency_hq_guid,
            .low_latency_hp => nvenc_bindings.preset_low_latency_hp_guid,
            .lossless_default => nvenc_bindings.preset_lossless_default_guid,
            .lossless_hp => nvenc_bindings.preset_lossless_hp_guid,
        };

        var config = std.mem.zeroes(nvenc_bindings.Config);
        config.version = nvenc_bindings.config_ver;

        var initialize_params = std.mem.zeroes(nvenc_bindings.InitializeParams);
        initialize_params.version = nvenc_bindings.initialize_params_ver;
        initialize_params.encodeConfig = &config;
        initialize_params.encodeGUID = codec_guid;
        initialize_params.presetGUID = preset_guid;
        initialize_params.encodeWidth = options.resolution.width;
        initialize_params.encodeHeight = options.resolution.height;
        initialize_params.darWidth = options.resolution.width;
        initialize_params.darHeight = options.resolution.height;
        initialize_params.frameRateNum = options.frame_rate.num;
        initialize_params.frameRateDen = options.frame_rate.den;
        initialize_params.enablePTD = 1; // Presentation order
        initialize_params.reportSliceOffsets = 0;
        initialize_params.enableSubFrameWrite = 0;
        initialize_params.maxEncodeWidth = options.resolution.width;
        initialize_params.maxEncodeHeight = options.resolution.height;
        initialize_params.enableMEOnlyMode = 0;
        initialize_params.enableEncodeAsync = false;

        var preset_config = std.mem.zeroes(nvenc_bindings.PresetConfig);
        preset_config.version = nvenc_bindings.preset_config_ver;
        preset_config.presetCfg.version = nvenc_bindings.config_ver;
        try status(nvenc_bindings.nvEncGetEncodePresetConfig.?(codec_guid, preset_guid, &preset_config));

        config.frameIntervalP = 1; // IPP mode
        config.gopLength = options.idr_interval orelse nvenc_bindings.infinite_goplength;

        var format = undefined;
        switch (options.codec) {
            .h264 => |h264_options| {
                config.profileGUID = switch (h264_options.profile) {
                    .baseline => nvenc_bindings.h264_profile_baseline_guid,
                    .main => nvenc_bindings.h264_profile_main_guid,
                    .high => nvenc_bindings.h264_profile_high_guid,
                    .high_444 => nvenc_bindings.h264_profile_high_444_guid,
                    .stereo => nvenc_bindings.h264_profile_stereo_guid,
                    .svc_temporal_scalabilty => nvenc_bindings.h264_profile_svc_temporal_scalabilty,
                    .progressive_high => nvenc_bindings.h264_profile_progressive_high_guid,
                    .constrained_high => nvenc_bindings.h264_profile_constrained_high_guid,
                };
                config.encodeCodecConfig.h264Config.chromaFormatIDC = switch (h264_options.format) {
                    .yuv420 => 1,
                    .yuv444 => 3,
                };
                format = h264_options.format.to_inner();
            },
            .hevc => |hevc_options| {
                config.profileGUID = switch (hevc_options.profile) {
                    .main => nvenc_bindings.hevc_profile_main_guid,
                    .main10 => nvenc_bindings.hevc_profile_main10_guid,
                    .frext => nvenc_bindings.hevc_profile_frext_guid,
                };
                config.encodeCodecConfig.h264Config.chromaFormatIDC = switch (hevc_options.profile) {
                    .yuv420, .yuv420_10bit => 1,
                    .yuv444, .yuv444_10bit => 3,
                };
                config.encodeCodecConfig.h264Config.pixelBitDepthMinus8 = switch (hevc_options.format) {
                    .yuv420_10bit, .yuv444_10bit => 2,
                    .yuv420, .yuv444 => 0,
                };
                format = hevc_options.format.to_inner();
            },
        }

        switch (options.rate_control) {
            .const_qp => |rc_opts| {
                config.rcParams.rateControlMode = .constqp;
                config.rcParams.constQP = .{
                    .qpInterP = rc_opts.inter_p,
                    .qpInterB = rc_opts.inter_b,
                    .qpIntra = rc_opts.intra,
                };
            },
            .vbr => |rc_opts| {
                config.rcParams.rateControlMode = .vbr;
                config.rcParams.averageBitRate = rc_opts.average_bitrate;
                config.rcParams.maxBitrate = rc_opts.max_bitrate;
            },
            .vbr_hq => |rc_opts| {
                config.rcParams.rateControlMode = .vbr_hq;
                config.rcParams.averageBitRate = rc_opts.average_bitrate;
                config.rcParams.maxBitrate = rc_opts.max_bitrate;
            },
            .cbr => |rc_opts| {
                config.rcParams.rateControlMode = .cbr;
                config.rcParams.averageBitRate = rc_opts.average_bitrate;
            },
            .cbr_hq => |rc_opts| {
                config.rcParams.rateControlMode = .cbr_hq;
                config.rcParams.averageBitRate = rc_opts.average_bitrate;
            },
            .cbr_lowdelay_hq => |rc_opts| {
                config.rcParams.rateControlMode = .cbr_lowdelay_hq;
                config.rcParams.averageBitRate = rc_opts.average_bitrate;
            },
        }

        try status(nvenc_bindings.nvEncInitializeEncoder(encoder, &initialize_params));
        errdefer status(nvenc_bindings.nvEncDestroyEncoder(encoder)) catch |err| {
            nvenc_log.err("failed to destroy encoder (err = {})", .{err});
        };

        const sequence_param_payload_cap = 1024;
        var sequence_param_payload_buf = allocator.alloc(u8, sequence_param_payload_cap);
        var sequence_param_payload_size: u32 = 0;
        var sequence_param_payload = std.mem.zeroes(nvenc_bindings.SequenceParamPayload);
        sequence_param_payload.version = nvenc_bindings.sequence_param_payload_ver;
        sequence_param_payload.spsppsBuffer = sequence_param_payload_buf.ptr;
        sequence_param_payload.inBufferSize = sequence_param_payload_cap;
        sequence_param_payload.outSPSPPSPayloadSize = &sequence_param_payload_size;
        try status(nvenc_bindings.nvEncGetSequenceParams.?(encoder, &sequence_param_payload));
        sequence_param_payload_buf = try allocator.realloc(sequence_param_payload_buf, sequence_param_payload_size);

        const cache_size = config.frameIntervalP + config.rcParams.lookaheadDepth;

        const io_cache_items = allocator.alloc(struct {}, cache_size);
        errdefer allocator.free(io_cache_items);

        for (&io_cache_items) |*item| {
            var create_bitstream_buffer = std.mem.zeroes(nvenc_bindings.CreateBitstreamBuffer);
            create_bitstream_buffer.version = nvenc_bindings.create_bitstream_buffer_ver;
            try status(nvenc_bindings.nvEncCreateBitstreamBuffer(encoder, &create_bitstream_buffer));
            item.* = .{
                .input_registered_resource = null,
                .output_bitstream = create_bitstream_buffer.bitstreamBuffer,
            };
        }

        errdefer {
            for (&io_cache_items) |*item| {
                status(nvenc_bindings.nvEncDestroyBitstreamBuffer(encoder, item.output_bitstream)) catch |err| {
                    nvenc_log.err("failed to destroy bitstream buffer (err = {})", .{err});
                };
            }
        }

        return Encoder{
            .context = context,
            .encoder = encoder,
            .format = format,
            .parameter_sets = sequence_param_payload_buf,
            .io_cache_items = io_cache_items,
            .io_cache = std.fifo.LinearFifo(IOCacheItem, .Slice).init(io_cache_items),
            .draining = false,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Encoder) void {
        self.unlock_current_output() catch |err| {
            nvenc_log.err("failed to unlock current bitstream (err = {})", .{err});
        };

        // User must flush encoder before deinit. If the cache has items still
        // it means the user did not flush properly.
        std.debug.assert(self.io_cache.readableLength() == 0);
        self.io_cache.deinit();

        for (&self.io_cache_items) |*item| {
            status(nvenc_bindings.nvEncDestroyBitstreamBuffer(self.encoder, item.output_bitstream)) catch |err| {
                nvenc_log.err("failed to destroy bitstream buffer (err = {})", .{err});
            };
        }
        self.allocator.free(self.io_cache_items);

        status(nvenc_bindings.?.nvEncDestroyEncoder(self.encoder)) catch |err| {
            nvenc_log.err("failed to destroy encoder (err = {})", .{err});
        };
    }

    /// Frame is valid until next call to decode, flush or deinit.
    pub fn encode(
        self: *Encoder,
        frame: struct {
            data: []u8,
            width: u32,
            height: u32,
            stride: u32,
        },
    ) !?[]const u8 {
        try self.unlock_current_output();

        if (self.drain()) |drained_output| return drained_output;

        // NOTE: If this hits it means that we do not have enough cache space
        // which should not be possible given we caclculated the max number of
        // buffered output we can expect for cache_size.
        std.debug.assert(self.io_cache.writableLength() > 0);

        const io_cache_item = &self.io_cache.writableSlice(0)[0];

        var register_resource = std.mem.zeroes(nvenc_bindings.RegisterResource);
        register_resource.version = nvenc_bindings.register_resource_ver;
        register_resource.resourceType = .cudadeviceptr;
        register_resource.resourceToRegister = frame.data.ptr;
        register_resource.width = frame.width;
        register_resource.height = frame.height;
        register_resource.pitch = frame.stride;
        register_resource.bufferFormat = self.format; // TODO: asserts!
        try status(nvenc_bindings.nvEncRegisterResource(self.encoder, &register_resource));
        errdefer status(nvenc_bindings.nvEncUnregisterResource(self.encoder, register_resource.registeredResource)) catch |err| {
            nvenc_log.err("failed to unregister resource (err = {})", .{err});
        };
        io_cache_item.input_registered_resource = register_resource.registeredResource;

        var map_input_resource = std.mem.zeroes(nvenc_bindings.MapInputResource);
        map_input_resource.version = nvenc_bindings.map_input_resource_ver;
        map_input_resource.registeredResource = register_resource.registeredResource;
        try status(nvenc_bindings.nvEncMapInputResource(self.encoder, &map_input_resource));
        errdefer status(nvenc_bindings.nvEncUnmapResource(self.encoder, map_input_resource.mappedResource)) catch |err| {
            nvenc_log.err("failed to unmap resource (err = {})", .{err});
        };
        io_cache_item.input_mapped_resource = map_input_resource.mappedResource;

        var pic_params = std.mem.zeroes(nvenc_bindings.PicParams);
        pic_params.version = nvenc_bindings.pic_params_ver;
        pic_params.pictureStruct = .frame;
        pic_params.inputBuffer = map_input_resource.mappedResource;
        pic_params.bufferFormat = self.format;
        pic_params.inputWidth = frame.width;
        pic_params.inputHeight = frame.height;
        pic_params.outputBitstream = io_cache_item.output_bitstream;
        const encode_status = try status_or_need_more_input(nvenc_bindings.nvEncEncodePicture(self.encoder, &pic_params));

        // This will cause head to increment.
        // The current input output pair will be cached.
        self.io_cache.update(1);

        // In case of success, we drain cached I/O. In most cases that will
        // only be the item we just put in the cache. In other cases if the
        // encoder has previously delayed output (i.e. need_more_input) we
        // continue draining.
        if (encode_status == .success) self.draining = true;

        return self.drain();
    }

    /// Before ending encoding call flush in a loop until it returns null.
    pub fn flush(self: *Encoder) ?[]const u8 {
        try self.unlock_current_output();

        if (self.drain()) |drained_output| return drained_output;

        // NOTE: NVIDIA docs seem unclear on what exactly this does but makes
        // sense that it will flush the internal buffer. In which case we
        // expect nvEncEncodePicture to always return success in this case.
        // Then we can drain the rest of the buffer.
        var pic_params = std.mem.zeroes(nvenc_bindings.PicParams);
        pic_params.version = nvenc_bindings.pic_params_ver;
        pic_params.encodePicFlags = nvenc_bindings.pic_flag_eos;
        try status(nvenc_bindings.nvEncEncodePicture(self.encoder, &pic_params));

        self.draining = true;

        return self.drain();
    }

    fn drain(self: *Encoder) ?[]const u8 {
        if (!self.draining) return null;

        if (self.io_cache.readableLength() == 0) {
            // entire cache was drained
            self.draining = false;
            return null;
        }

        const read_item = self.io_cache.readableSliceOfLen(1)[0];

        try status(nvenc_bindings.nvEncUnmapResource(self.encoder, read_item.input_mapped_resource));
        read_item.input_mapped_resource = null;
        try status(nvenc_bindings.nvEncUnregisterResource(self.encoder, read_item.input_registered_resource));
        read_item.input_registered_resource = null;

        var lock_bitstream = std.mem.zeroes(nvenc_bindings.LockBitstream);
        lock_bitstream.outputBitstream = read_item.output_bitstream;
        lock_bitstream.doNotWait = false; // this is mandatory in sync mode
        try status(nvenc_bindings.nvEncLockBitstream(self.encoder, &lock_bitstream));
        errdefer status(nvenc_bindings.nvEncUnlockBitstream.?(self.encoder, read_item.output_bitstream)) catch |err| {
            nvenc_log.err("failed to unlock bitstream (err = {})", .{err});
        };

        // store pointer to bitstream in cur_output_ptr so it can be unlocked
        // and invalidated on next iteration of decode
        self.cur_output_ptr = read_item.output_bitstream;

        // This will increment the tail pointer.
        // The I/O pair is marked as done/drained.
        self.io_cache.discard(1);

        const slice_ptr = @as([*]u8, @ptrCast(lock_bitstream.bitstreamBufferPtr));
        const slice = slice_ptr[0..lock_bitstream.bitstreamSizeInBytes];
        return slice;
    }

    fn unlock_current_output(self: *Encoder) !void {
        if (self.cur_output_ptr) |output_ptr| {
            try status(nvenc_bindings.nvEncUnlockBitstream.?(self.encoder, output_ptr));
            self.cur_output_ptr = null;
        }
    }
};

fn status(ret: nvenc_bindings.Status) Error!void {
    switch (ret) {
        .success => return,
        .no_encode_device => return error.NoEncodeDevice,
        .unsupported_device => return error.UnsupportedDevice,
        .invalid_encoderdevice => return error.InvalidEncoderDevice,
        .invalid_device => return error.InvalidDevice,
        .device_not_exist => return error.DeviceNotExist,
        .invalid_ptr => return error.InvalidPtr,
        .invalid_event => return error.InvalidEvent,
        .invalid_param => return error.InvalidParam,
        .invalid_call => return error.InvalidCall,
        .out_of_memory => return error.OutOfMemory,
        .encoder_not_initialized => return error.EncoderNotInitialized,
        .unsupported_param => return error.UnsupportedParam,
        .lock_busy => return error.LockBusy,
        .not_enough_buffer => return error.NotEnoughBuffer,
        .invalid_version => return error.InvalidVersion,
        .map_failed => return error.MapFailed,
        .need_more_input => return error.NeedMoreInput,
        .encoder_busy => return error.EncoderBusy,
        .event_not_registerd => return error.EventNotRegisterd,
        .generic => return error.Generic,
        .incompatible_client_key => return error.IncompatibleClientKey,
        .unimplemented => return error.Unimplemented,
        .resource_register_failed => return error.ResourceRegisterFailed,
        .resource_not_registered => return error.ResourceNotRegistered,
        .resource_not_mapped => return error.ResourceNotMapped,
    }
}

/// Same as status but need_more_input is not considered an error.
/// In case of success returns either success or need_more_input.
fn status_or_need_more_input(ret: nvenc_bindings.Status) Error!enum { success, need_more_input } {
    switch (ret) {
        .success => return .success,
        .need_more_input => return .need_more_input,
        .no_encode_device => return error.NoEncodeDevice,
        .unsupported_device => return error.UnsupportedDevice,
        .invalid_encoderdevice => return error.InvalidEncoderDevice,
        .invalid_device => return error.InvalidDevice,
        .device_not_exist => return error.DeviceNotExist,
        .invalid_ptr => return error.InvalidPtr,
        .invalid_event => return error.InvalidEvent,
        .invalid_param => return error.InvalidParam,
        .invalid_call => return error.InvalidCall,
        .out_of_memory => return error.OutOfMemory,
        .encoder_not_initialized => return error.EncoderNotInitialized,
        .unsupported_param => return error.UnsupportedParam,
        .lock_busy => return error.LockBusy,
        .not_enough_buffer => return error.NotEnoughBuffer,
        .invalid_version => return error.InvalidVersion,
        .map_failed => return error.MapFailed,
        .encoder_busy => return error.EncoderBusy,
        .event_not_registerd => return error.EventNotRegisterd,
        .generic => return error.Generic,
        .incompatible_client_key => return error.IncompatibleClientKey,
        .unimplemented => return error.Unimplemented,
        .resource_register_failed => return error.ResourceRegisterFailed,
        .resource_not_registered => return error.ResourceNotRegistered,
        .resource_not_mapped => return error.ResourceNotMapped,
    }
}

pub const Error = error{
    NoEncodeDevice,
    UnsupportedDevice,
    InvalidEncoderDevice,
    InvalidDevice,
    DeviceNotExist,
    InvalidPtr,
    InvalidEvent,
    InvalidParam,
    InvalidCall,
    OutOfMemory,
    EncoderNotInitialized,
    UnsupportedParam,
    LockBusy,
    NotEnoughBuffer,
    InvalidVersion,
    MapFailed,
    NeedMoreInput,
    EncoderBusy,
    EventNotRegisterd,
    Generic,
    IncompatibleClientKey,
    Unimplemented,
    ResourceRegisterFailed,
    ResourceNotRegistered,
    ResourceNotMapped,
};
