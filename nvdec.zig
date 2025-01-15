const std = @import("std");

const nvdec_bindings = @import("nvdec_bindings");

const nvdec_log = std.log.scoped(.nvdec_log);

// TODO: NvDecoder.cpp (reference implementation) also includes context handling
// (constantly pushing popping a specific context) but I feel like we should leave
// that to the user.
// TODO: Also left out context lock for now

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvdec_bindings.load;

pub const Codec = nvdec_bindings.VideoCodec;

/// NV12 decoded frame.
/// Important: The data is behind a device pointer!
pub const Frame = struct {
    data: struct {
        y: []u8,
        /// U and V planes are weaved in NV12.
        uv: []u8,
    },
    /// Pitch means stride in NVIDIA speak.
    /// NV12 frames have the same stride for the Y pland and UV plane. UV values are weaved.
    pitch: u32,
    dims: struct {
        width: u32,
        height: u32,
    },
    timestamp: u64,

    inline fn toDevicePtrU64(self: *const Frame) u64 {
        return @intCast(@intFromPtr(self.data.y.ptr));
    }
};

pub const DecoderOptions = struct {
    codec: Codec,
    resolution: struct {
        width: u32,
        height: u32,
    },
};

const num_output_surfaces = 2;

/// NVDEC Video Decoder.
/// Decoder is not thread safe.
pub const Decoder = struct {
    parser: nvdec_bindings.VideoParser = null,
    decoder: nvdec_bindings.VideoDecoder = null,

    allocator: std.mem.Allocator,

    frame_dims: ?struct {
        width: u32,
        height: u32,
    } = null,

    /// Holds all frames that have been decoded but not yet returned to caller.
    frame_buffer: [num_output_surfaces]?Frame = [_]?Frame{null} ** num_output_surfaces,
    /// Index to last returned frame. This frame needs to be unmapped on next decode iteration.
    frame_in_flight: ?usize = null,

    error_state: ?Error = null,

    pub fn create(options: DecoderOptions, allocator: std.mem.Allocator) !*Decoder {
        var self = try allocator.create(Decoder);
        errdefer allocator.destroy(self);
        self.* = .{ .allocator = allocator };

        var parser_params = std.mem.zeroes(nvdec_bindings.ParserParams);
        parser_params.CodecType = options.codec;
        parser_params.ulMaxNumDecodeSurfaces = 1;
        parser_params.ulMaxDisplayDelay = 0; // always low-latency
        parser_params.pUserData = self;
        parser_params.pfnSequenceCallback = handleSequenceCallback;
        parser_params.pfnDecodePicture = handleDecodePicture;
        parser_params.pfnDisplayPicture = handleDisplayPicture;
        try result(nvdec_bindings.cuvidCreateVideoParser.?(&self.parser, &parser_params));

        return self;
    }

    pub fn destroy(self: *Decoder) void {
        self.frame_buffer_unmap_in_flight() catch @panic("failed to unmap in flight frame");
        // Check there are no more frames in the buffer. Otherwise the caller may have forgotten
        // to flush before destorying.
        std.debug.assert(self.frame_buffer_next() catch @panic("frame buffer error during destroy") == null);

        if (self.parser != null)
            result(nvdec_bindings.cuvidDestroyVideoParser.?(self.parser)) catch @panic("failed to destroy video parser");
        if (self.decoder != null)
            result(nvdec_bindings.cuvidDestroyDecoder.?(self.decoder)) catch @panic("failed to destroy decoder");
        self.allocator.destroy(self);
    }

    pub fn decode(self: *Decoder, data: []const u8) !?*const Frame {
        // XXX: It is very important that we first call frame here since it will unmap a possibly
        // in flight frame as well as flush the buffer before moving on with decoding.
        if (try self.frame_buffer_next()) |frame| return frame;

        var packet = std.mem.zeroes(nvdec_bindings.SourceDataPacket);
        if (data.len > 0) {
            packet.payload = data.ptr;
            packet.payload_size = @intCast(data.len);
            packet.flags = nvdec_bindings.packet_flags.timestamp;
        } else {
            packet.payload = null;
            packet.payload_size = 0;
            packet.flags = nvdec_bindings.packet_flags.timestamp | nvdec_bindings.packet_flags.endofstream;
        }

        try result(nvdec_bindings.cuvidParseVideoData.?(self.parser, &packet));

        // handle possible errors in callback
        if (self.error_state) |err| {
            self.error_state = null;
            return err;
        }

        return try self.frame_buffer_next();
    }

    /// Before ending decoding call flush in a loop until it returns null.
    pub fn flush(self: *Decoder) !?*const Frame {
        // calling decode with an empty slice means flush
        return self.decode(&.{});
    }

    /// Go through frame buffer and unmap in flight frame, then return pointer to next mapped frame.
    fn frame_buffer_next(self: *Decoder) !?*const Frame {
        try self.frame_buffer_unmap_in_flight();

        for (0.., self.frame_buffer) |index, frame_slot| {
            if (frame_slot) |frame| {
                self.frame_in_flight = index;
                return &frame;
            }
        }
        return null;
    }

    fn frame_buffer_unmap_in_flight(self: *Decoder) !void {
        if (self.frame_in_flight) |in_flight| {
            const frame = &self.frame_buffer[in_flight].?;
            try result(nvdec_bindings.cuvidUnmapVideoFrame64.?(self.decoder, frame.toDevicePtrU64()));
            self.frame_buffer[in_flight] = null;
        }
    }

    fn handleSequenceCallback(context: ?*anyopaque, format: ?*nvdec_bindings.VideoFormat) callconv(.C) c_int {
        var self: *Decoder = @ptrCast(@alignCast(context));

        if (self.error_state != null) return 0;

        // self.decoder != null means handleSequenceCallback was called before,
        // which means the deocder wants to recongfigure which is not implemented
        // at this time
        if (self.decoder != null) return 0;

        // roughly similar to NvDecoder:
        // https://github.com/NVIDIA/video-sdk-samples/blob/aa3544dcea2fe63122e4feb83bf805ea40e58dbe/Samples/NvCodec/NvDecoder/NvDecoder.cpp#L93
        const num_decode_surfaces: c_int = switch (format.?.codec) {
            .vp9 => 12,
            .h264, .h264_mvc, .h264_svc => 20,
            .hevc => 20,
            else => 8,
        };

        var decode_caps = std.mem.zeroes(nvdec_bindings.DecodeCaps);
        decode_caps.eCodecType = format.?.codec;
        decode_caps.eChromaFormat = format.?.chroma_format;
        decode_caps.nBitDepthMinus8 = format.?.bit_depth_luma_minus8;
        result(nvdec_bindings.cuvidGetDecoderCaps.?(&decode_caps)) catch |err| {
            self.error_state = err;
            return 0;
        };

        if (decode_caps.bIsSupported == 0) {
            nvdec_log.err("codec not supported (codec = {})", .{decode_caps.eCodecType});
            return 0;
        }
        if (format.?.coded_width > decode_caps.nMaxWidth or format.?.coded_height > decode_caps.nMaxHeight) {
            nvdec_log.err("resolution not supported (max resolution = {}x{})", .{ decode_caps.nMaxWidth, decode_caps.nMaxHeight });
            return 0;
        }
        if (((format.?.coded_width >> 4) * (format.?.coded_height >> 4)) > decode_caps.nMaxMBCount) {
            nvdec_log.err("MB count too high (max MB count = {})", .{decode_caps.nMaxMBCount});
            return 0;
        }

        var decoder_create_info = std.mem.zeroes(nvdec_bindings.CreateInfo);
        decoder_create_info.CodecType = format.?.codec;
        decoder_create_info.ChromaFormat = format.?.chroma_format;
        // // This is what NvDecoder does, it basically mimics the content format.
        // decoder_create_info.OutputFormat = if (format.bit_depth_luma_minus8 > 0) .p016 else .nv12;
        // decoder_create_info.bitDepthMinus8 = format.bit_depth_luma_minus8;
        // force output format nv12
        decoder_create_info.OutputFormat = .nv12;
        decoder_create_info.bitDepthMinus8 = 0;
        decoder_create_info.DeinterlaceMode = .weave;
        decoder_create_info.ulNumOutputSurfaces = num_output_surfaces;
        decoder_create_info.ulCreationFlags = nvdec_bindings.create_flags.prefer_CUVID;
        decoder_create_info.ulNumDecodeSurfaces = @intCast(num_decode_surfaces);
        // decoder_create_info.vidLock = lock;
        decoder_create_info.ulWidth = format.?.coded_width;
        decoder_create_info.ulHeight = format.?.coded_height;
        decoder_create_info.ulMaxWidth = 0;
        decoder_create_info.ulMaxHeight = 0;
        decoder_create_info.ulTargetWidth = format.?.coded_width;
        decoder_create_info.ulTargetHeight = format.?.coded_height;

        // frame_dims stores calculated frame dimensions for later when we need them to
        // correctly slice frame data
        self.frame_dims = .{
            .width = @intCast(format.?.display_area.right - format.?.display_area.left),
            .height = @intCast(format.?.display_area.bottom - format.?.display_area.top),
        };

        result(nvdec_bindings.cuvidCreateDecoder.?(&self.decoder, &decoder_create_info)) catch |err| {
            self.error_state = err;
            return 0;
        };

        return num_decode_surfaces;
    }

    fn handleDecodePicture(context: ?*anyopaque, pic_params: ?*nvdec_bindings.PicParams) callconv(.C) c_int {
        const self: *Decoder = @ptrCast(@alignCast(context));

        if (self.error_state != null) return 0;

        result(nvdec_bindings.cuvidDecodePicture.?(self.decoder, pic_params)) catch |err| {
            self.error_state = err;
            return 0;
        };

        return 1;
    }

    fn handleDisplayPicture(context: ?*anyopaque, parser_disp_info: ?*nvdec_bindings.ParserDispInfo) callconv(.C) c_int {
        var self: *Decoder = @ptrCast(@alignCast(context));

        if (self.error_state != null) return 0;

        var proc_params = std.mem.zeroes(nvdec_bindings.ProcParams);
        proc_params.progressive_frame = parser_disp_info.?.progressive_frame;
        proc_params.second_field = parser_disp_info.?.repeat_first_field + 1;
        proc_params.top_field_first = parser_disp_info.?.top_field_first;
        proc_params.unpaired_field = if (parser_disp_info.?.repeat_first_field < 0) 1 else 0;
        // TODO: By leaving this uncommented we are defaulting to the global stream which
        // is not ideal especially in multi-decoder situations.
        // If we are going to create entirely new contexts for every decoder (NvDecoder does this)
        // then it's okay since there is no points in having separate streams anyway.
        // proc_params.output_stream = m_cuvidStream;

        var frame_data_ptr_u64: u64 = 0;
        var frame_pitch: c_uint = 0;
        result(nvdec_bindings.cuvidMapVideoFrame64.?(
            self.decoder,
            parser_disp_info.?.picture_index,
            &frame_data_ptr_u64,
            &frame_pitch,
            &proc_params,
        )) catch |err| {
            self.error_state = err;
            return 0;
        };

        std.debug.assert(frame_data_ptr_u64 != 0);

        var get_decode_status = std.mem.zeroes(nvdec_bindings.GetDecodeStatus);
        result(nvdec_bindings.cuvidGetDecodeStatus.?(self.decoder, parser_disp_info.?.picture_index, &get_decode_status)) catch |err| {
            self.error_state = err;
            return 0;
        };

        if (get_decode_status.decodeStatus == .err) nvdec_log.err("decoding error", .{});
        if (get_decode_status.decodeStatus == .err_concealed) nvdec_log.warn("decoding error concealed", .{});

        const frame_data_ptr: [*]u8 = @ptrFromInt(frame_data_ptr_u64);
        const width = self.frame_dims.?.width;
        const height = self.frame_dims.?.height;
        const pitch: u32 = @intCast(frame_pitch);
        // nv12 is a biplanar format so all we need here is to calculate the offset
        // to the UV plane (which contains both U and V)
        const uv_offset = height * pitch;

        for (0..num_output_surfaces) |frame_buffer_index| {
            if (self.frame_buffer[frame_buffer_index] != null)
                continue;

            self.frame_buffer[frame_buffer_index] = .{
                .data = .{
                    .y = frame_data_ptr[0 .. height * pitch],
                    .uv = frame_data_ptr[uv_offset .. uv_offset + (height * pitch)],
                },
                .pitch = @intCast(frame_pitch),
                .dims = .{
                    .width = width,
                    .height = height,
                },
                .timestamp = @intCast(parser_disp_info.?.timestamp),
            };

            return 1;
        }

        nvdec_log.err("frame buffer full (num output surfaces = {})", .{num_output_surfaces});
        return 0;
    }
};

fn result(ret: nvdec_bindings.Result) Error!void {
    switch (ret) {
        .success => return,
        .invalid_value => return Error.InvalidValue,
        .out_of_memory => return Error.OutOfMemory,
        .not_initialized => return Error.NotInitialized,
        .deinitialized => return Error.Deinitialized,
        .profiler_disabled => return Error.ProfilerDisabled,
        .profiler_not_initialized => return Error.ProfilerNotInitialized,
        .profiler_already_started => return Error.ProfilerAlreadyStarted,
        .profiler_already_stopped => return Error.ProfilerAlreadyStopped,
        .stub_library => return Error.StubLibrary,
        .device_unavailable => return Error.DeviceUnavailable,
        .no_device => return Error.NoDevice,
        .invalid_device => return Error.InvalidDevice,
        .device_not_licensed => return Error.DeviceNotLicensed,
        .invalid_image => return Error.InvalidImage,
        .invalid_context => return Error.InvalidContext,
        .context_already_current => return Error.ContextAlreadyCurrent,
        .map_failed => return Error.MapFailed,
        .unmap_failed => return Error.UnmapFailed,
        .array_is_mapped => return Error.ArrayIsMapped,
        .already_mapped => return Error.AlreadyMapped,
        .no_binary_for_gpu => return Error.NoBinaryForGpu,
        .already_acquired => return Error.AlreadyAcquired,
        .not_mapped => return Error.NotMapped,
        .not_mapped_as_array => return Error.NotMappedAsArray,
        .not_mapped_as_pointer => return Error.NotMappedAsPointer,
        .ecc_uncorrectable => return Error.EccUncorrectable,
        .unsupported_limit => return Error.UnsupportedLimit,
        .context_already_in_use => return Error.ContextAlreadyInUse,
        .peer_access_unsupported => return Error.PeerAccessUnsupported,
        .invalid_ptx => return Error.InvalidPtx,
        .invalid_graphics_context => return Error.InvalidGraphicsContext,
        .nvlink_uncorrectable => return Error.NvlinkUncorrectable,
        .jit_compiler_not_found => return Error.JitCompilerNotFound,
        .unsupported_ptx_version => return Error.UnsupportedPtxVersion,
        .jit_compilation_disabled => return Error.JitCompilationDisabled,
        .unsupported_exec_affinity => return Error.UnsupportedExecAffinity,
        .unsupported_devside_sync => return Error.UnsupportedDevsideSync,
        .invalid_source => return Error.InvalidSource,
        .file_not_found => return Error.FileNotFound,
        .shared_object_symbol_not_found => return Error.SharedObjectSymbolNotFound,
        .shared_object_init_failed => return Error.SharedObjectInitFailed,
        .operating_system => return Error.OperatingSystem,
        .invalid_handle => return Error.InvalidHandle,
        .illegal_state => return Error.IllegalState,
        .lossy_query => return Error.LossyQuery,
        .not_found => return Error.NotFound,
        .not_ready => return Error.NotReady,
        .illegal_address => return Error.IllegalAddress,
        .launch_out_of_resources => return Error.LaunchOutOfResources,
        .launch_timeout => return Error.LaunchTimeout,
        .launch_incompatible_texturing => return Error.LaunchIncompatibleTexturing,
        .peer_access_already_enabled => return Error.PeerAccessAlreadyEnabled,
        .peer_access_not_enabled => return Error.PeerAccessNotEnabled,
        .primary_context_active => return Error.PrimaryContextActive,
        .context_is_destroyed => return Error.ContextIsDestroyed,
        .assert => return Error.Assert,
        .too_many_peers => return Error.TooManyPeers,
        .host_memory_already_registered => return Error.HostMemoryAlreadyRegistered,
        .host_memory_not_registered => return Error.HostMemoryNotRegistered,
        .hardware_stack_error => return Error.HardwareStackError,
        .illegal_instruction => return Error.IllegalInstruction,
        .misaligned_address => return Error.MisalignedAddress,
        .invalid_address_space => return Error.InvalidAddressSpace,
        .invalid_pc => return Error.InvalidPc,
        .launch_failed => return Error.LaunchFailed,
        .cooperative_launch_too_large => return Error.CooperativeLaunchTooLarge,
        .not_permitted => return Error.NotPermitted,
        .not_supported => return Error.NotSupported,
        .system_not_ready => return Error.SystemNotReady,
        .system_driver_mismatch => return Error.SystemDriverMismatch,
        .compat_not_supported_on_device => return Error.CompatNotSupportedOnDevice,
        .mps_connection_failed => return Error.MpsConnectionFailed,
        .mps_rpc_failure => return Error.MpsRpcFailure,
        .mps_server_not_ready => return Error.MpsServerNotReady,
        .mps_max_clients_reached => return Error.MpsMaxClientsReached,
        .mps_max_connections_reached => return Error.MpsMaxConnectionsReached,
        .mps_client_terminated => return Error.MpsClientTerminated,
        .cdp_not_supported => return Error.CdpNotSupported,
        .cdp_version_mismatch => return Error.CdpVersionMismatch,
        .stream_capture_unsupported => return Error.StreamCaptureUnsupported,
        .stream_capture_invalidated => return Error.StreamCaptureInvalidated,
        .stream_capture_merge => return Error.StreamCaptureMerge,
        .stream_capture_unmatched => return Error.StreamCaptureUnmatched,
        .stream_capture_unjoined => return Error.StreamCaptureUnjoined,
        .stream_capture_isolation => return Error.StreamCaptureIsolation,
        .stream_capture_implicit => return Error.StreamCaptureImplicit,
        .captured_event => return Error.CapturedEvent,
        .stream_capture_wrong_thread => return Error.StreamCaptureWrongThread,
        .timeout => return Error.Timeout,
        .graph_exec_update_failure => return Error.GraphExecUpdateFailure,
        .external_device => return Error.ExternalDevice,
        .invalid_cluster_size => return Error.InvalidClusterSize,
        .function_not_loaded => return Error.FunctionNotLoaded,
        .invalid_resource_type => return Error.InvalidResourceType,
        .invalid_resource_configuration => return Error.InvalidResourceConfiguration,
        .unknown => return Error.Unknown,
    }
}

/// Contains all errors from bindings as well as some extra errors that exist only in the wrapper.
pub const Error = error{
    InvalidValue,
    OutOfMemory,
    NotInitialized,
    Deinitialized,
    ProfilerDisabled,
    ProfilerNotInitialized,
    ProfilerAlreadyStarted,
    ProfilerAlreadyStopped,
    StubLibrary,
    DeviceUnavailable,
    NoDevice,
    InvalidDevice,
    DeviceNotLicensed,
    InvalidImage,
    InvalidContext,
    ContextAlreadyCurrent,
    MapFailed,
    UnmapFailed,
    ArrayIsMapped,
    AlreadyMapped,
    NoBinaryForGpu,
    AlreadyAcquired,
    NotMapped,
    NotMappedAsArray,
    NotMappedAsPointer,
    EccUncorrectable,
    UnsupportedLimit,
    ContextAlreadyInUse,
    PeerAccessUnsupported,
    InvalidPtx,
    InvalidGraphicsContext,
    NvlinkUncorrectable,
    JitCompilerNotFound,
    UnsupportedPtxVersion,
    JitCompilationDisabled,
    UnsupportedExecAffinity,
    UnsupportedDevsideSync,
    InvalidSource,
    FileNotFound,
    SharedObjectSymbolNotFound,
    SharedObjectInitFailed,
    OperatingSystem,
    InvalidHandle,
    IllegalState,
    LossyQuery,
    NotFound,
    NotReady,
    IllegalAddress,
    LaunchOutOfResources,
    LaunchTimeout,
    LaunchIncompatibleTexturing,
    PeerAccessAlreadyEnabled,
    PeerAccessNotEnabled,
    PrimaryContextActive,
    ContextIsDestroyed,
    Assert,
    TooManyPeers,
    HostMemoryAlreadyRegistered,
    HostMemoryNotRegistered,
    HardwareStackError,
    IllegalInstruction,
    MisalignedAddress,
    InvalidAddressSpace,
    InvalidPc,
    LaunchFailed,
    CooperativeLaunchTooLarge,
    NotPermitted,
    NotSupported,
    SystemNotReady,
    SystemDriverMismatch,
    CompatNotSupportedOnDevice,
    MpsConnectionFailed,
    MpsRpcFailure,
    MpsServerNotReady,
    MpsMaxClientsReached,
    MpsMaxConnectionsReached,
    MpsClientTerminated,
    CdpNotSupported,
    CdpVersionMismatch,
    StreamCaptureUnsupported,
    StreamCaptureInvalidated,
    StreamCaptureMerge,
    StreamCaptureUnmatched,
    StreamCaptureUnjoined,
    StreamCaptureIsolation,
    StreamCaptureImplicit,
    CapturedEvent,
    StreamCaptureWrongThread,
    Timeout,
    GraphExecUpdateFailure,
    ExternalDevice,
    InvalidClusterSize,
    FunctionNotLoaded,
    InvalidResourceType,
    InvalidResourceConfiguration,
    Unknown,
};
