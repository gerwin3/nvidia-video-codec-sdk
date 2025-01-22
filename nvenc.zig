const std = @import("std");

const nvenc_bindings = @import("nvenc_bindings");

const nvenc_log = std.log.scoped(.nvenc_log);

pub const cuda = @import("cuda");

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvenc_bindings.load;

/// Input frame.
/// Important: The data is stored on device and cannot be accessed directly.
pub const Frame = struct {
    pub const Format = enum {
        /// 4:2:0, semi-planar Y and weaved UV.
        nv12,
        /// 4:2:0, planar YVU.
        yv12,
        /// 4:2:0, planar YUV (called IYUV in nvEncodeAPI.h for historical reasons)
        yuv420,
        /// 4:4:4, planar YUV
        yuv444,
        /// 4:2:0, planar YUV, 10 bit
        yuv420_10bit,
        /// 4:4:4, planar YUV, 10 bit
        yuv444_10bit,
        /// Alpha layer RGB
        argb,
        /// Alpha layer RGB (10 bit)
        argb10,
        /// Alpha layer YUV
        ayuv,
        /// Alpha layer BGR
        abgr,
        /// Alpha layer BGR, 10 bit
        abgr10,
    };

    data: cuda.DevicePtr,
    format: Format,

    /// Pitch means stride in NVIDIA speak.
    pitch: u32,
    dims: struct {
        width: u32,
        height: u32,
    },
};

pub const H264Format = enum {
    yuv420,
    yuv444,
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
};

pub const HEVCProfile = enum {
    main,
    main10,
    frext,
};

/// Codec to use. Choose from H.264 and HEVC (H.265).
/// Note that for each codec you can optionally select a profile and format.
/// The profile will be forcefully applied to the encoder config. It is
/// recommended to not set them, in which case the preset default will be used.
pub const Codec = union(enum) {
    h264: struct {
        profile: ?H264Profile = null,
        format: ?H264Format = null,
    },
    hevc: struct {
        profile: ?HEVCProfile = null,
        format: ?HEVCFormat = null,
    },
};

pub const Preset = enum {
    p1,
    p2,
    p3,
    p4,
    p5,
    p6,
    p7,
};

pub const Tuning = enum {
    high_quality,
    low_latency,
    ultra_low_latency,
    lossless,
};

pub const RateControl = union(enum) {
    const_qp: struct {
        inter_p: i32,
        inter_b: i32,
        intra: i32,
    },
    vbr: struct {
        average_bitrate: u32,
        max_bitrate: u32,
    },
    cbr: struct {
        bitrate: u32,
    },
};

pub const EncoderOptions = struct {
    codec: Codec,
    preset: Preset = .p1,
    tuning: Tuning = .high_quality,
    resolution: struct {
        width: u32,
        height: u32,
    },
    frame_rate: struct { num: u32, den: u32 } = .{ .num = 30, .den = 1 },
    idr_interval: ?u32 = null,
    rate_control: ?RateControl = .{ .vbr = .{
        .average_bitrate = 5_000_000,
        .max_bitrate = 10_000_000,
    } },
};

pub const Encoder = struct {
    const InputOutputPair = struct {
        input_registered_resource: nvenc_bindings.RegisteredPtr = null,
        input_mapped_resource: nvenc_bindings.InputPtr = null,
        output_bitstream: nvenc_bindings.OutputPtr = null,
    };

    encoder: ?*anyopaque,
    parameter_sets: []u8,

    // The IO buffer is needed to keep track of input/output pairs that have been
    // buffered by the encoder. If the encoder produces need_more_input it
    // means more input is needed to produce a frame. In this case we must keep
    // track of the input buffers so we can keep them registered and mapped
    // until we can drain the encoder buffer, which is the next time
    // nvEncEncodePicture returns success.
    io_buffer_items: []InputOutputPair,
    io_buffer: LinearFifoPool(InputOutputPair),

    allocator: std.mem.Allocator,

    pub fn init(context: *cuda.Context, options: EncoderOptions, allocator: std.mem.Allocator) !Encoder {
        var encoder: ?*anyopaque = null;

        var params = std.mem.zeroes(nvenc_bindings.OpenEncodeSessionExParams);
        params.version = nvenc_bindings.open_encode_session_ex_params_ver;
        params.deviceType = .cuda;
        params.device = context.inner;
        params.apiVersion = nvenc_bindings.api_version;

        try status(nvenc_bindings.nvEncOpenEncodeSessionEx.?(&params, &encoder));

        const codec_guid = switch (options.codec) {
            .h264 => nvenc_bindings.codec_h264_guid,
            .hevc => nvenc_bindings.codec_hevc_guid,
        };

        const preset_guid = switch (options.preset) {
            .p1 => nvenc_bindings.preset_p1,
            .p2 => nvenc_bindings.preset_p2,
            .p3 => nvenc_bindings.preset_p3,
            .p4 => nvenc_bindings.preset_p4,
            .p5 => nvenc_bindings.preset_p5,
            .p6 => nvenc_bindings.preset_p6,
            .p7 => nvenc_bindings.preset_p7,
        };

        const tuning_info = switch (options.tuning) {
            .high_quality => nvenc_bindings.TuningInfo.high_quality,
            .low_latency => nvenc_bindings.TuningInfo.low_latency,
            .ultra_low_latency => nvenc_bindings.TuningInfo.ultra_low_latency,
            .lossless => nvenc_bindings.TuningInfo.lossless,
        };

        var config = std.mem.zeroes(nvenc_bindings.Config);
        config.version = nvenc_bindings.config_ver;

        var preset_config = std.mem.zeroes(nvenc_bindings.PresetConfig);
        preset_config.version = nvenc_bindings.preset_config_ver;
        preset_config.presetCfg.version = nvenc_bindings.config_ver;
        try status(nvenc_bindings.nvEncGetEncodePresetConfigEx.?(encoder, codec_guid, preset_guid, tuning_info, &preset_config));
        config = preset_config.presetCfg;

        if (options.idr_interval) |idr_interval| config.gopLength = idr_interval;

        switch (options.codec) {
            .h264 => |h264_options| {
                if (h264_options.profile) |profile| {
                    config.profileGUID = switch (profile) {
                        .baseline => nvenc_bindings.h264_profile_baseline_guid,
                        .main => nvenc_bindings.h264_profile_main_guid,
                        .high => nvenc_bindings.h264_profile_high_guid,
                        .high_444 => nvenc_bindings.h264_profile_high_444_guid,
                        .stereo => nvenc_bindings.h264_profile_stereo_guid,
                        .svc_temporal_scalabilty => nvenc_bindings.h264_profile_svc_temporal_scalabilty,
                        .progressive_high => nvenc_bindings.h264_profile_progressive_high_guid,
                        .constrained_high => nvenc_bindings.h264_profile_constrained_high_guid,
                    };
                }
                if (h264_options.format) |format| {
                    config.encodeCodecConfig.h264Config.chromaFormatIDC = switch (format) {
                        .yuv420 => 1,
                        .yuv444 => 3,
                    };
                }
            },
            .hevc => |hevc_options| {
                if (hevc_options.profile) |profile| {
                    config.profileGUID = switch (profile) {
                        .main => nvenc_bindings.hevc_profile_main_guid,
                        .main10 => nvenc_bindings.hevc_profile_main10_guid,
                        .frext => nvenc_bindings.hevc_profile_frext_guid,
                    };
                }
                if (hevc_options.format) |format| {
                    config.encodeCodecConfig.hevcConfig.bitfields.chromaFormatIDC = switch (format) {
                        .yuv420, .yuv420_10bit => 1,
                        .yuv444, .yuv444_10bit => 3,
                    };
                    config.encodeCodecConfig.hevcConfig.bitfields.pixelBitDepthMinus8 = switch (format) {
                        .yuv420_10bit, .yuv444_10bit => 2,
                        .yuv420, .yuv444 => 0,
                    };
                }
            },
        }

        if (options.rate_control) |rate_control| {
            switch (rate_control) {
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
                    config.rcParams.maxBitRate = rc_opts.max_bitrate;
                },
                .cbr => |rc_opts| {
                    config.rcParams.rateControlMode = .cbr;
                    config.rcParams.averageBitRate = rc_opts.bitrate;
                },
            }
        }

        var initialize_params = std.mem.zeroes(nvenc_bindings.InitializeParams);
        initialize_params.version = nvenc_bindings.initialize_params_ver;
        initialize_params.encodeConfig = &config;
        initialize_params.encodeGUID = codec_guid;
        initialize_params.presetGUID = preset_guid;
        initialize_params.tuningInfo = tuning_info;
        initialize_params.encodeWidth = options.resolution.width;
        initialize_params.encodeHeight = options.resolution.height;
        initialize_params.darWidth = options.resolution.width;
        initialize_params.darHeight = options.resolution.height;
        initialize_params.frameRateNum = options.frame_rate.num;
        initialize_params.frameRateDen = options.frame_rate.den;
        initialize_params.enablePTD = 1; // Presentation order
        initialize_params.maxEncodeWidth = options.resolution.width;
        initialize_params.maxEncodeHeight = options.resolution.height;
        initialize_params.enableEncodeAsync = 0;

        try status(nvenc_bindings.nvEncInitializeEncoder.?(encoder, &initialize_params));
        errdefer status(nvenc_bindings.nvEncDestroyEncoder.?(encoder)) catch unreachable;

        const sequence_param_payload_cap = 1024;
        var sequence_param_payload_buf = try allocator.alloc(u8, sequence_param_payload_cap);
        var sequence_param_payload_size: u32 = 0;
        var sequence_param_payload = std.mem.zeroes(nvenc_bindings.SequenceParamPayload);
        sequence_param_payload.version = nvenc_bindings.sequence_param_payload_ver;
        sequence_param_payload.spsppsBuffer = sequence_param_payload_buf.ptr;
        sequence_param_payload.inBufferSize = sequence_param_payload_cap;
        sequence_param_payload.outSPSPPSPayloadSize = &sequence_param_payload_size;
        status(nvenc_bindings.nvEncGetSequenceParams.?(encoder, &sequence_param_payload)) catch unreachable;
        sequence_param_payload_buf = try allocator.realloc(sequence_param_payload_buf, sequence_param_payload_size);
        errdefer allocator.free(sequence_param_payload_buf);

        const io_buffer_size: usize = @intCast(config.frameIntervalP + config.rcParams.lookaheadDepth);
        const io_buffer_items = try allocator.alloc(InputOutputPair, io_buffer_size);
        errdefer allocator.free(io_buffer_items);

        for (io_buffer_items) |*item| item.* = .{};
        errdefer for (io_buffer_items) |item| {
            if (item.output_bitstream) |output_bitstream| {
                status(nvenc_bindings.nvEncDestroyBitstreamBuffer.?(encoder, output_bitstream)) catch unreachable;
            }
        };

        for (io_buffer_items) |*item| {
            var create_bitstream_buffer = std.mem.zeroes(nvenc_bindings.CreateBitstreamBuffer);
            create_bitstream_buffer.version = nvenc_bindings.create_bitstream_buffer_ver;
            try status(nvenc_bindings.nvEncCreateBitstreamBuffer.?(encoder, &create_bitstream_buffer));
            item.* = .{
                .input_registered_resource = null,
                .output_bitstream = create_bitstream_buffer.bitstreamBuffer,
            };
        }

        // TODO: perf: Use nvEncSetIOCudaStreams to assign CUDA streams.

        return Encoder{
            .encoder = encoder,
            .parameter_sets = sequence_param_payload_buf,
            .io_buffer_items = io_buffer_items,
            .io_buffer = LinearFifoPool(InputOutputPair).init(io_buffer_items),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Encoder) void {
        self.allocator.free(self.parameter_sets);

        // User must flush encoder before deinit. If the buffer has items still
        // it means the user did not flush properly.
        std.debug.assert(self.io_buffer.empty());

        for (self.io_buffer_items) |*item| {
            status(nvenc_bindings.nvEncDestroyBitstreamBuffer.?(self.encoder, item.output_bitstream)) catch unreachable;
        }
        self.allocator.free(self.io_buffer_items);

        status(nvenc_bindings.nvEncDestroyEncoder.?(self.encoder)) catch |err| {
            nvenc_log.err("failed to destroy encoder (err = {})", .{err});
        };
    }

    /// Frame is valid until next call to decode, flush or deinit.
    pub fn encode(self: *Encoder, frame: *const Frame, writer: anytype) !void {
        // NOTE: If this hits it means that we do not have enough buffer space
        // which should not be possible given we caclculated the max number of
        // buffered output we can expect for io_buffer_size.
        const input_output_pair = self.io_buffer.reserve() catch unreachable;

        const buffer_format: nvenc_bindings.BufferFormat = switch (frame.format) {
            .nv12 => .nv12,
            .yv12 => .yv12,
            .yuv420 => .iyuv,
            .yuv444 => .yuv444,
            .yuv420_10bit => .yuv420_10bit,
            .yuv444_10bit => .yuv444_10bit,
            .argb => .argb,
            .argb10 => .argb10,
            .ayuv => .ayuv,
            .abgr => .abgr,
            .abgr10 => .abgr10,
        };

        var register_resource = std.mem.zeroes(nvenc_bindings.RegisterResource);
        register_resource.version = nvenc_bindings.register_resource_ver;
        register_resource.resourceType = .cudadeviceptr;
        register_resource.resourceToRegister = @ptrFromInt(@as(usize, @intCast(frame.data)));
        register_resource.width = frame.dims.width;
        register_resource.height = frame.dims.height;
        register_resource.pitch = frame.pitch;
        register_resource.bufferFormat = buffer_format;
        try status(nvenc_bindings.nvEncRegisterResource.?(self.encoder, &register_resource));
        errdefer status(nvenc_bindings.nvEncUnregisterResource.?(self.encoder, register_resource.registeredResource)) catch unreachable;
        input_output_pair.input_registered_resource = register_resource.registeredResource;

        var map_input_resource = std.mem.zeroes(nvenc_bindings.MapInputResource);
        map_input_resource.version = nvenc_bindings.map_input_resource_ver;
        map_input_resource.registeredResource = register_resource.registeredResource;
        try status(nvenc_bindings.nvEncMapInputResource.?(self.encoder, &map_input_resource));
        errdefer status(nvenc_bindings.nvEncUnmapInputResource.?(self.encoder, map_input_resource.mappedResource)) catch unreachable;
        input_output_pair.input_mapped_resource = map_input_resource.mappedResource;

        var pic_params = std.mem.zeroes(nvenc_bindings.PicParams);
        pic_params.version = nvenc_bindings.pic_params_ver;
        pic_params.pictureStruct = .frame;
        pic_params.inputBuffer = map_input_resource.mappedResource;
        pic_params.bufferFmt = buffer_format;
        pic_params.inputWidth = frame.dims.width;
        pic_params.inputHeight = frame.dims.height;
        pic_params.outputBitstream = input_output_pair.output_bitstream;
        const encode_status = try status_or_need_more_input(nvenc_bindings.nvEncEncodePicture.?(self.encoder, &pic_params));

        // NOTE: If encoder returns success it means we can now drain all
        // queued IO. If it returns need_more_input we need to wait until the
        // next time it returns success (no data will be written in that case).
        if (encode_status == .success) try self.drain(writer);
    }

    /// Before ending encoding call this function to flush buffered output.
    pub fn flush(self: *Encoder, writer: anytype) !void {
        // NOTE: NVIDIA docs seem unclear on what exactly this does but makes
        // sense that it will flush the internal buffer. In which case we
        // expect nvEncEncodePicture to always return success in this case.
        // Then we can drain the rest of the buffer.
        var pic_params = std.mem.zeroes(nvenc_bindings.PicParams);
        pic_params.version = nvenc_bindings.pic_params_ver;
        pic_params.encodePicFlags = nvenc_bindings.pic_flag_eos;
        try status(nvenc_bindings.nvEncEncodePicture(self.encoder, &pic_params));

        try self.drain(writer);
    }

    fn drain(self: *Encoder, writer: anytype) !void {
        while (self.io_buffer.pop()) |input_output_pair| {
            status(nvenc_bindings.nvEncUnmapInputResource.?(self.encoder, input_output_pair.input_mapped_resource)) catch unreachable;
            status(nvenc_bindings.nvEncUnregisterResource.?(self.encoder, input_output_pair.input_registered_resource)) catch unreachable;

            var lock_bitstream = std.mem.zeroes(nvenc_bindings.LockBitstream);
            lock_bitstream.version = nvenc_bindings.lock_bitstream_ver;
            lock_bitstream.outputBitstream = input_output_pair.output_bitstream;
            lock_bitstream.bitfields.doNotWait = false; // this is mandatory in sync mode
            status(nvenc_bindings.nvEncLockBitstream.?(self.encoder, &lock_bitstream)) catch unreachable;

            defer status(nvenc_bindings.nvEncUnlockBitstream.?(self.encoder, input_output_pair.output_bitstream)) catch unreachable;

            const slice_ptr = @as([*]u8, @ptrCast(lock_bitstream.bitstreamBufferPtr));
            const slice = slice_ptr[0..lock_bitstream.bitstreamSizeInBytes];

            try writer.writeAll(slice);
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

/// Linear FIFO queue similar to std.LinearFifo. Implementation adapted from
/// TigerBeetle stdx.RingBuffer.
///
/// The queue acts as a ring buffer but instead of pushing and popping items it
/// operates on pointer to the underlying store. Essentially the items are
/// already there. Calling reserve returns a pointer to the current tail and
/// advances the tail. Calling pop returns a pointer to the current head and
/// advances the head.
pub fn LinearFifoPool(comptime T: type) type {
    return struct {
        const Self = @This();

        resevoir: []T,
        index: usize = 0,
        count: usize = 0,

        pub fn init(data: []T) Self {
            std.debug.assert(data.len > 0);
            return .{ .resevoir = data };
        }

        /// Reserve next item and return pointer to it.
        pub inline fn reserve(self: *Self) error{NoSpaceLeft}!*T {
            if (self.count == self.resevoir.len) return error.NoSpaceLeft;
            defer self.count += 1;
            return &self.resevoir[(self.index + self.count) % self.resevoir.len];
        }

        /// Pop item in FIFO order with respect to the order they were reserved.
        /// After calling pop the respective slot may be reserved again.
        pub inline fn pop(self: *Self) ?*T {
            if (self.empty()) return null;
            const result = &self.resevoir[self.index];
            self.index += 1;
            self.index %= self.resevoir.len;
            self.count -= 1;
            return result;
        }

        pub inline fn empty(self: *const Self) bool {
            return self.count == 0;
        }
    };
}

test "LinearFifoPool" {
    var data: [4]u32 = .{ 1, 2, 3, 4 };
    var fifo = LinearFifoPool(u32).init(&data);
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[0]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[1]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[2]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[3]));
    try std.testing.expectEqual(fifo.reserve(), error.NoSpaceLeft);
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[0]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[0]));
    try std.testing.expectEqual(fifo.reserve(), error.NoSpaceLeft);
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[1]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[2]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[3]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[0]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, null));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[1]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[2]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[3]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[1]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[2]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[3]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[0]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[1]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[2]));
    try std.testing.expectEqual(fifo.reserve(), @as(error{NoSpaceLeft}!*u32, &data[3]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[0]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[1]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[2]));
    try std.testing.expectEqual(fifo.pop(), @as(?*u32, &data[3]));
}
