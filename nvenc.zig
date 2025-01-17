const std = @import("std");

const nvenc_bindings = @import("nvenc_bindings");

const nvenc_log = std.log.scoped(.nvenc_log);

pub const cuda = @import("cuda"); // TODO?

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvenc_bindings.load;

pub const H264Format = enum {
    yuv420,
    yuv444,

    fn to_inner(self: H264Format) nvenc_bindings.BufferFormat {
        return switch (self) {
            .yuv420 => .nv12, // TODO? maybe???
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
            .yuv420 => .nv12, // TODO? maybe???
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
    device: cuda.Device = 0,
};

pub const Encoder = struct {
    context: cuda.Context,
    encoder: ?*anyopaque,
    input_buffer: []u8,
    bitstream_buffer: []const u8,

    pub fn init(options: EncoderOptions) !Encoder {
        const context = try cuda.Context.init(options.device);
        errdefer context.deinit();

        var encoder: ?*anyopaque = null;

        var params = std.mem.zeroes(nvenc_bindings.OpenSessionExParams);
        params.version = nvenc_bindings.open_encode_session_ex_params_ver;
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
                config.encodeCodecConfig.h264Config.chromaFormatIDC = switch (h264_options.profile) {
                    .yuv420 => 1,
                    .yuv444 => 3,
                };
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
                config.encodeCodecConfig.h264Config.pixelBitDepthMinus8 = switch (hevc_options.profile) {
                    .yuv420_10bit, .yuv444_10bit => 2,
                    .yuv420, .yuv444 => 0,
                };
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

        // TODO: num buffers
        // m_nEncoderBuffer = m_encodeConfig.frameIntervalP + m_encodeConfig.rcParams.lookaheadDepth + m_nExtraOutputDelay;
        // m_nOutputDelay = m_nEncoderBuffer - 1;

        // TODO: not sure about this we want to load the data from GPU actually
        // var create_input_buffer = std.mem.zeroes(nvenc_bindings.CreateInputBuffer);
        // create_input_buffer.version = nvenc_bindings.create_input_buffer_ver;
        //
        // try status(nvenc_bindings.nvEncCreateInputBuffer(encoder, &create_input_buffer));
        // errdefer status(nvenc_bindings.nvEncDestroyInputBuffer(encoder, create_input_buffer.inputBuffer)) catch |err| {
        //     nvenc_log.err("failed to destroy input buffer (err = {})", .{err});
        // };
        //
        // std.debug.assert(create_input_buffer.width == options.resolution.width);
        // std.debug.assert(create_input_buffer.height == options.resolution.height);
        // std.debug.assert(create_input_buffer.bufferFmt == switch (options.codec) {
        //     .h264 => |h264_options| h264_options.format,
        //     .hevc => |hevc_options| hevc_options.format,
        // });

        // TODO: store pointer
        // TODO: destroy

        var create_bitstream_buffer = std.mem.zeroes(nvenc_bindings.CreateBitstreamBuffer);
        create_bitstream_buffer.version = nvenc_bindings.create_bitstream_buffer_ver;

        try status(nvenc_bindings.nvEncCreateBitstreamBuffer(encoder, &create_bitstream_buffer));
        errdefer status(nvenc_bindings.nvEncDestroyBitstreamBuffer(encoder, create_bitstream_buffer.bitstreamBuffer)) catch |err| {
            nvenc_log.err("failed to destroy bitstream buffer (err = {})", .{err});
        };

        // TODO: store pointer
        // TODO: destroy

        return Encoder{
            .context = context,
            .encoder = encoder,
        };
    }

    // NOTE: The NvEncoder implementation uses a cirular buffer to keep input
    // and output buffers. For a while I thought this was due to the underlying
    // nvEncEncodePicture being somehow async, but this is NOT the case
    // (assuming enableEncodeAsync is set to false of course). The reason
    // NvEncoder does this is because it has a built-in output delay feature
    // that can probably help saturation in the multi-threaded case. Anyway, we
    // can just use a single input surface and output buffer and all will be
    // fine.

    // TODO: Still not sure how to handle NV_ENC_ERR_NEED_MORE_INPUT. Opened a
    // thread here:
    // https://forums.developer.nvidia.com/t/how-to-handle-buffers-when-nvencencodepicture-produces-nv-enc-err-need-more-input/320435

    // TODO: The client must call NvEncLockBitstream with flag
    // NV_ENC_LOCK_BITSTREAM::doNotWait set to 0, so that the lock call blocks
    // until the hardware encoder finishes writing the output bitstream. The
    // client can then operate on the generated bitstream data and call
    // NvEncUnlockBitstream. This is the only mode supported on Linux.

    // TODO: Notifying the End of Input Stream: To notify the end of input
    // stream, the client must call NvEncEncodePicture with the flag
    // NV_ENC_PIC_PARAMS:: encodePicFlags set to NV_ENC_FLAGS_EOS and all other
    // members of NV_ENC_PIC_PARAMS set to 0. No input buffer is required while
    // calling NvEncEncodePicture for EOS notification. EOS notification
    // effectively flushes the encoder. This can be called multiple times in a
    // single encode session. This operation however must be done before
    // closing the encode session.

    // TODO: NvEncGetSequenceParams
    // we may want this for openh264 as well...?

    pub fn deinit(self: *Encoder) void {
        status(nvenc_bindings.?.nvEncDestroyEncoder(self.encoder)) catch |err| {
            nvenc_log.err("failed to destroy encoder (err = {})", .{err});
        };

        self.context.deinit();
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
