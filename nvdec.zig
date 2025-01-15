const std = @import("std");

const nvdec_bindings = @import("nvdec_bindings");

const nvdec_log = std.log.scoped(.nvdec_log);

pub const cuda = @import("cuda");

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = nvdec_bindings.load;

pub const Codec = nvdec_bindings.VideoCodec;

/// NV12 decoded frame.
/// Important: The data is stored on device and cannot be accessed directly.
pub const Frame = struct {
    data: struct {
        y: []volatile u8,
        /// U and V planes are weaved in NV12.
        uv: []volatile u8,
    },
    /// Pitch means stride in NVIDIA speak.
    /// NV12 frames have the same stride for the Y pland and UV plane. UV values are weaved.
    pitch: u32,
    dims: struct {
        width: u32,
        height: u32,
    },
    timestamp: u64,
};

pub const DecoderOptions = struct {
    codec: Codec,
    resolution: struct {
        width: u32,
        height: u32,
    },
    device: cuda.Device = 0,
};

const num_output_surfaces = 2;

/// NVDEC Video Decoder.
/// Decoder is not thread safe.
pub const Decoder = struct {
    /// Helper struct for frame buffering.
    /// This has gotten quite complex so refactoring it out made it easier to reason about.
    pub const Buffer = struct {
        items: [num_output_surfaces]struct {
            frame: Frame,
            valid: bool,
        },
        cur_borrowed: ?usize,

        pub fn init() Buffer {
            var buffer = Buffer{
                .items = undefined,
                .cur_borrowed = null,
            };
            @memset(&buffer.items, .{ .frame = undefined, .valid = false });
            return buffer;
        }

        /// Make sure to also call invalidate_borrowed_frame() before calling deinit.
        pub fn deinit(self: *Buffer) void {
            // just some checks:
            // - no frame may be borrowed at this time or the caller forgot to invalidate the
            //   borrowed frame before deinit
            // - no frames may be active or the caller may have forgotten to flush the decoder
            std.debug.assert(self.cur_borrowed == null);
            const next_item_should_not_be_there = self.next() catch |err| {
                nvdec_log.err("failed to pull next item during buffer deinit (err = {})", .{err});
            };
            std.debug.assert(next_item_should_not_be_there == null);
        }

        pub fn push(self: *Buffer, frame: Frame) !void {
            for (0..self.items.len) |index| {
                if (self.items[index].valid)
                    continue;

                self.items[index] = .{ .valid = true, .frame = frame };
                return;
            }

            nvdec_log.err("frame buffer full (len = {})", .{self.items.len});
            return Error.FrameBufferFull;
        }

        pub fn next(self: *Buffer) !?*const Frame {
            std.debug.assert(self.cur_borrowed == null);

            for (0..self.items.len) |index| {
                if (self.items[index].valid) {
                    self.cur_borrowed = index;
                    return &self.items[index].frame;
                }
            }
            return null;
        }

        pub fn invalidate_borrowed_frame(self: *Buffer, inner_decoder: nvdec_bindings.VideoDecoder) !void {
            if (self.cur_borrowed) |cur_borrowed| {
                std.debug.assert(self.items[cur_borrowed].valid);

                try result(nvdec_bindings.cuvidUnmapVideoFrame64.?(
                    inner_decoder,
                    cuda.devicePtrFromSlice(self.items[cur_borrowed].frame.data.y),
                ));
                self.items[cur_borrowed].valid = false;
                self.cur_borrowed = null;
            }
        }
    };

    context: cuda.Context,
    parser: nvdec_bindings.VideoParser = null,
    decoder: nvdec_bindings.VideoDecoder = null,

    allocator: std.mem.Allocator,

    buffer: Buffer,
    surface_info: ?struct {
        frame_width: u32,
        frame_height: u32,
        surface_height: u32,
    } = null,
    error_state: ?Error = null,

    pub fn create(options: DecoderOptions, allocator: std.mem.Allocator) !*Decoder {
        var self = try allocator.create(Decoder);
        errdefer allocator.destroy(self);

        const context = try cuda.Context.init(options.device);
        errdefer context.deinit();

        var buffer = Buffer.init();
        errdefer buffer.deinit();

        self.* = .{
            .context = context,
            .buffer = buffer,
            .allocator = allocator,
        };

        var parser_params = std.mem.zeroes(nvdec_bindings.ParserParams);
        parser_params.CodecType = options.codec;
        parser_params.ulMaxNumDecodeSurfaces = 1;
        parser_params.ulMaxDisplayDelay = 0; // always low-latency
        parser_params.pUserData = self;
        parser_params.pfnSequenceCallback = handleSequenceCallback;
        parser_params.pfnDecodePicture = handleDecodePicture;
        parser_params.pfnDisplayPicture = handleDisplayPicture;
        try result(nvdec_bindings.cuvidCreateVideoParser.?(&self.parser, &parser_params));
        errdefer result(nvdec_bindings.cuvidDestroyVideoParser.?(self.parser)) catch |err| {
            nvdec_log.err("failed to destroy video parser (err = {})", .{err});
        };

        return self;
    }

    pub fn destroy(self: *Decoder) void {
        // this little dance is what NvDecoder does so we do it too...
        self.context.push() catch {};
        self.context.pop() catch {};

        self.buffer.invalidate_borrowed_frame(self.decoder) catch |err| {
            nvdec_log.err("failed to invalidate borrowed frame (err = {})", .{err});
        };

        if (self.parser != null) {
            result(nvdec_bindings.cuvidDestroyVideoParser.?(self.parser)) catch |err| {
                nvdec_log.err("failed to destroy video parser (err = {})", .{err});
            };
        }
        if (self.decoder != null) {
            result(nvdec_bindings.cuvidDestroyDecoder.?(self.decoder)) catch |err| {
                nvdec_log.err("failed to destroy decoder (err = {})", .{err});
            };
        }

        self.buffer.deinit();
        self.context.deinit();

        self.allocator.destroy(self);
    }

    pub fn decode(self: *Decoder, data: []const u8) !?*const Frame {
        try self.buffer.invalidate_borrowed_frame(self.decoder);
        if (try self.buffer.next()) |frame| return frame;

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

        // handle possible errors from one of the callbacks
        if (self.error_state) |err| {
            self.error_state = null;
            return err;
        }

        return try self.buffer.next();
    }

    /// Before ending decoding call flush in a loop until it returns null.
    pub fn flush(self: *Decoder) !?*const Frame {
        // calling decode with an empty slice means flush
        return self.decode(&.{});
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

        self.context.push() catch |err| {
            self.error_state = err;
            return 0;
        };
        result(nvdec_bindings.cuvidGetDecoderCaps.?(&decode_caps)) catch |err| {
            self.error_state = err;
            return 0;
        };
        self.context.pop() catch |err| {
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
        self.surface_info = .{
            .frame_width = @intCast(format.?.display_area.right - format.?.display_area.left),
            .frame_height = @intCast(format.?.display_area.bottom - format.?.display_area.top),
            .surface_height = @intCast(format.?.coded_height),
        };

        self.context.push() catch |err| {
            self.error_state = err;
            return 0;
        };
        result(nvdec_bindings.cuvidCreateDecoder.?(&self.decoder, &decoder_create_info)) catch |err| {
            self.error_state = err;
            return 0;
        };
        self.context.pop() catch |err| {
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

        var frame_data: cuda.DevicePtr = 0;
        var frame_pitch: c_uint = 0;
        result(nvdec_bindings.cuvidMapVideoFrame64.?(
            self.decoder,
            parser_disp_info.?.picture_index,
            &frame_data,
            &frame_pitch,
            &proc_params,
        )) catch |err| {
            self.error_state = err;
            return 0;
        };
        std.debug.assert(frame_data != 0);

        var get_decode_status = std.mem.zeroes(nvdec_bindings.GetDecodeStatus);
        result(nvdec_bindings.cuvidGetDecodeStatus.?(self.decoder, parser_disp_info.?.picture_index, &get_decode_status)) catch |err| {
            self.error_state = err;
            return 0;
        };

        if (get_decode_status.decodeStatus == .err) nvdec_log.err("decoding error", .{});
        if (get_decode_status.decodeStatus == .err_concealed) nvdec_log.warn("decoding error concealed", .{});

        const frame_width = self.surface_info.?.frame_width;
        const frame_height = self.surface_info.?.frame_height;
        const surface_height = self.surface_info.?.surface_height;
        const pitch: u32 = @intCast(frame_pitch);

        // nv12 is a biplanar format so all we need here is to calculate the offset
        // to the UV plane (which contains both U and V) using the surface height
        const uv_offset = surface_height * pitch;

        self.buffer.push(.{
            .data = .{
                .y = cuda.sliceFromDevicePtr(frame_data, 0, frame_height * pitch),
                .uv = cuda.sliceFromDevicePtr(frame_data, uv_offset, uv_offset + ((frame_height / 2) * pitch)),
            },
            .pitch = @intCast(frame_pitch),
            .dims = .{
                .width = frame_width,
                .height = frame_height,
            },
            .timestamp = @intCast(parser_disp_info.?.timestamp),
        }) catch |err| {
            self.error_state = err;
            return 0;
        };

        return 1;
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
} || cuda.Error || error{FrameBufferFull};
