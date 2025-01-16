const std = @import("std");

const nvenc_bindings = @import("nvenc_bindings");

const nvenc_log = std.log.scoped(.nvenc_log);

pub const cuda = @import("cuda"); // TODO?

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvenc_bindings.load;

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

pub const RateControlMode = nvenc_bindings.ParamsRcMode;

pub const EncoderOptions = struct {
    codec: Codec,
    preset: Preset = .default,
    resolution: struct {
        width: u32,
        height: u32,
    },
    frame_rate: struct { num: u32, den: u32 } = .{ .num = 30, .den = 1 },
    idr_interval: ?u32 = null,
    rate_control_mode: ?RateControlMode = null,
    device: cuda.Device = 0,
};

pub const Encoder = struct {
    context: cuda.Context,
    encoder: ?*anyopaque,

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
        initialize_params.enablePTD = 1;
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
        if (options.rate_control_mode) |rate_conrol_mode|
            config.rcParams.rateControlMode = rate_conrol_mode;

        // not sure but NvEncoder.cpp does it so we do it
        if (initialize_params.presetGUID != nvenc_bindings.preset_lossless_default_guid and
            initialize_params.presetGUID != nvenc_bindings.preset_lossless_hp_guid)
            initialize_params.encodeConfig.rcParams.constQP = .{ .qpInterP = 28, .qpInterB = 31, .qpIntra = 25 };

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
                initialize_params.encodeConfig.encodeCodecConfig.h264Config.chromaFormatIDC = switch (h264_options.profile) {
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
                initialize_params.encodeConfig.encodeCodecConfig.h264Config.chromaFormatIDC = switch (hevc_options.profile) {
                    .yuv420, .yuv420_10bit => 1,
                    .yuv444, .yuv444_10bit => 3,
                };
                initialize_params.encodeConfig.encodeCodecConfig.h264Config.pixelBitDepthMinus8 = switch (hevc_options.profile) {
                    .yuv420_10bit, .yuv444_10bit => 2,
                    .yuv420, .yuv444 => 0,
                };
            },
        }

        // TODO: CreateEncoder continue

        return Encoder{
            .context = context,
            .encoder = encoder,
        };
    }

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
