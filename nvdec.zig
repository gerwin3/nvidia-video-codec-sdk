const std = @import("std");

const nvdec_bindings = @import("nvdec_bindings");

const nvdec_log = std.log.scoped(.nvdec_log);

// TODO: NvDecoder.cpp (reference implementation) also includes context handling
// (constantly pushing popping a specific context) but I feel like we should leave
// that to the user.
// TODO: Also left out context lock for now

pub const Codec = nvdec_bindings.CodecType;

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
    frame_buffer: [num_output_surfaces]?Frame = [_]null,
    /// Index to last returned frame. This frame needs to be unmapped on next decode iteration.
    frame_in_flight: ?usize = null,

    pub fn create(options: DecoderOptions, allocator: std.mem.Allocator) !*Decoder {
        var self = allocator.create(Decoder);
        self.* = .{ .allocator = allocator };

        var parser_params = std.mem.zeroes(nvdec_bindings.ParserParams);
        parser_params.CodecType = options.codec,
        parser_params.ulMaxNumDecodeSurfaces = 1;
        parser_params.ulMaxDisplayDelay = 0; // always low-latency
        parser_params.pUserData = self;
        parser_params.pfnSequenceCallback = handleSequenceCallback;
        parser_params.pfnDecodePicture = handleDecodePicture;
        parser_params.pfnDisplayPicture = handleDisplayPicture;
        try result(nvdec_bindings.cuvidCreateVideoParser(&self.parser));

        return self;
    }

    pub fn destroy(self: *Decoder) void {
        self.frame_buffer_unmap_in_flight();
        // Check there are no more frames in the buffer. Otherwise the caller may have forgotten
        // to flush before destorying.
        std.debug.assert(self.frame() == null);

        if (self.parser != null) nvdec_bindings.cuvidDestroyVideoParser(self.parser);
        if (self.decoder != null) nvdec_bindings.cuvidDestroyDecoder(self.parser);
        self.allocator.free(self);
    }

    pub fn decode(self: *Decoder, data: []const u8) !?*const Frame {
        // XXX: It is very important that we first call frame here since it will unmap a possibly
        // in flight frame as well as flush the buffer before moving on with decoding.
        if (try self.frame()) |frame| return frame;

        var packet = std.mem.zeroes(nvdec_bindings.SourceDataPacket);
        if (data.len > 0) {
            packet.payload = data.ptr;
            packet.payload_size = data.len;
            packet.flags = nvdec_bindings.pkt_timestamp;
        } else {
            packet.payload = null;
            packet.payload_size = 0;
            packet.flags = nvdec_bindings.pkt_timestamp | nvdec_bindings.pkt_endofstream;
        }
        try result(nvdec_bindings.cuvidParseVideoData(self.parser, &packet));

        return try self.frame();
    }

    /// Before ending decoding call flush in a loop until it returns null.
    pub fn flush(self: *Decoder, data: []const u8) !?*const Frame {
        // calling decode with an empty slice means flush
        return self.decode(&.{});
    }

    /// Go through frame buffer and unmap in flight frame, then return pointer to next mapped frame.
    fn frame(self: *Decoder) !?*const Frame {
        try self.frame_buffer_unmap_in_flight();

        for (self.frame_buffer) |index, frame_slot| {
            if (frame_slot) |frame| {
                return &frame;
                self.frame_in_flight = index;
            }
        }
        return null;
    }

    fn frame_buffer_unmap_in_flight() !void {
        if (self.frame_in_flight) |in_flight| {
            const frame = &self.frame_buffer[in_flight].?;
            try result(nvdec_bindings.cuvidUnmapVideoFrame64.?(self.decoder, frame.toDevicePtrU64()));
            self.frame_buffer[in_flight] = null;
        }
    }

    fn handleSequenceCallback(self: *Decoder, format: ?*VideoFormat) c_int {
        var ret = 0;

        // self.decoder != null means handleSequenceCallback was called before,
        // which means the deocder wants to recongfigure which is not implemented
        // at this time
        if (self.decoder != null) return 0;

        // roughly similar to NvDecoder:
        // https://github.com/NVIDIA/video-sdk-samples/blob/aa3544dcea2fe63122e4feb83bf805ea40e58dbe/Samples/NvCodec/NvDecoder/NvDecoder.cpp#L93
        const num_decode_surfaces = switch (format.codec) {
            .vp9 => 12,
            .h264, .h264_mvc, .h264_svc => 20,
            .hevc => 20,
            else => 8,
        };

        var decode_caps = std.mem.zeroes(nvdec_bindings.DecodeCaps);
        decode_caps.eCodecType = format.codec;
        decode_caps.eChromaFormat = format.chroma_format;
        decode_caps.nBitDepthMinus8 = format.bit_depth_luma_minus8;
        result(nvdec_bindings.cuvidGetDecoderCaps.?(&decode_caps)) catch return 0;

        if (!decode_caps.bIsSupported)
            return Error.unsupported_codec;
        if (format.codec_width> decode_caps.nMaxWidth or format.codec_height > decode_caps.nMaxHeight)
            return Error.unsupported_resolution;
        if (((format.coded_width>>4)*(format.coded_height>>4)) > decode_caps.nMaxMBCount)
            return Error.unsupported_mbcount;

        var decoder_create_info = std.mem.zeroes(nvdec_bindings.CreateInfo);
        decoder_create_info.CodecType = format.codec;
        decoder_create_info.ChromaFormat = format.chroma_format;
        // // This is what NvDecoder does, it basically mimics the content format.
        // decoder_create_info.OutputFormat = if (format.bit_depth_luma_minus8 > 0) .p016 else .nv12;
        // decoder_create_info.bitDepthMinus8 = format.bit_depth_luma_minus8;
        // force output format nv12
        decoder_create_info.OutputFormat = .nv12;
        decoder_create_info.bitDepthMinus8 = 0;
        decoder_create_info.DeinterlaceMode = .weave;
        decoder_create_info.ulNumOutputSurfaces = num_output_surfaces;
        decoder_create_info.ulCreationFlags = cudaVideoCreate_PreferCUVID;
        decoder_create_info.ulNumDecodeSurfaces = num_decode_surfaces;
        // decoder_create_info.vidLock = lock;
        decoder_create_info.ulWidth = format.coded_width;
        decoder_create_info.ulHeight = format.coded_height;
        decoder_create_info.ulMaxWidth = 0;
        decoder_create_info.ulMaxHeight = 0;
        decoder_create_info.ulTargetWidth = format.coded_width;
        decoder_create_info.ulTargetHeight = format.coded_height;

        // frame_dims stores calculated frame dimensions for later when we need them to
        // correctly slice frame data
        self.frame_dims = .{
            .width = format.display_area.right - format.display_area.left,
            .height = format.display_area.bottom - format.display_area.top,
        };

        result(nvdec_bindings.cuvidCreateDecoder.?(&self.decoder, &decoder_create_info)) catch return 0;

        return num_decode_surfaces;
    }

    fn handleDecodePicture(self: *Decoder, pic_params: ?*PicParams) c_int {
        result(nvdec_bindings.cuvidDecodePicture.?(self.decoder, pic_params)) catch return 0;
        return 1;
    }

    fn handleDisplayPicture(self: *Decoder, parser_disp_info: ?*ParserDispInfo) c_int {
        var proc_params = std.mem.zeroes(nvdec_bindings.ProcParams);
        proc_params.progressive_frame = parser_disp_info.progressive_frame;
        proc_params.second_field = parser_disp_info.repeat_first_field + 1;
        proc_params.top_field_first = parser_disp_info.top_field_first;
        proc_params.unpaired_field = parser_disp_info.repeat_first_field < 0;
        // TODO: By leaving this uncommented we are defaulting to the global stream which
        // is not ideal especially in multi-decoder situations.
        // If we are going to create entirely new contexts for every decoder (NvDecoder does this)
        // then it's okay since there is no points in having separate streams anyway.
        // proc_params.output_stream = m_cuvidStream;

        var frame_data_ptr_u64: u64 = 0;
        var frame_pitch: c_uint = 0;
        result(nvdec_bindings.cuvidMapVideoFrame64.?(self.decoder, parser_disp_info.picture_index, &frame_data_ptr_u64, &frame_pitch, &proc_params,)) catch return 0;
        std.debug.assert(frame_data_ptr_u64 != 0);

        var get_decode_status = std.mem.zeroes(nvdec_bindings.GetDecodeStatus);
        result(nvdec_bindings.cuvidGetDecodeStatus.?(self.decoder, parser_disp_info.picture_index, &get_decode_status)) catch return 0;
        if (get_decode_status.decodeStatus == .err) nvdec_log.err("decoding error");
        if (get_decode_status.decodeStatus == .err_concealed) nvdec_log.warn("decoding error");

        const frame_data_ptr: [*]u8 = @ptrFromInt(frame_data_ptr);
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
                    .y = frame_data_ptr[0:height * pitch],
                    .uv = frame_data_ptr[uv_offset:uv_offset + (height * pitch)],
                },
                .pitch = @intCast(frame_pitch),
                .dims = .{
                    .width = width,
                    .height = height,
                },
                .timestamp = @intCast(parser_disp_info.timestamp),
            };

            return 1;
        }

        nvdec_log.err("frame buffer full (num output surfaces = {})", .{ num_output_surfaces });
        return 0;
    }
};

fn result(ret: nvdec_bindings.Result) Error!void {
    switch (ret) {
        .success => return,
        else => @as(Error, @enumFromInt(@intFromEnum(ret))),
    }
}

/// Contains all errors from bindings as well as some extra errors that exist only in the wrapper.
pub const Error = enum(c_uint) {
    invalid_value = 1,
    out_of_memory = 2,
    not_initialized = 3,
    deinitialized = 4,
    profiler_disabled = 5,
    profiler_not_initialized = 6,
    profiler_already_started = 7,
    profiler_already_stopped = 8,
    stub_library = 34,
    device_unavailable = 46,
    no_device = 100,
    invalid_device = 101,
    device_not_licensed = 102,
    invalid_image = 200,
    invalid_context = 201,
    context_already_current = 202,
    map_failed = 205,
    unmap_failed = 206,
    array_is_mapped = 207,
    already_mapped = 208,
    no_binary_for_gpu = 209,
    already_acquired = 210,
    not_mapped = 211,
    not_mapped_as_array = 212,
    not_mapped_as_pointer = 213,
    ecc_uncorrectable = 214,
    unsupported_limit = 215,
    context_already_in_use = 216,
    peer_access_unsupported = 217,
    invalid_ptx = 218,
    invalid_graphics_context = 219,
    nvlink_uncorrectable = 220,
    jit_compiler_not_found = 221,
    unsupported_ptx_version = 222,
    jit_compilation_disabled = 223,
    unsupported_exec_affinity = 224,
    unsupported_devside_sync = 225,
    invalid_source = 300,
    file_not_found = 301,
    shared_object_symbol_not_found = 302,
    shared_object_init_failed = 303,
    operating_system = 304,
    invalid_handle = 400,
    illegal_state = 401,
    lossy_query = 402,
    not_found = 500,
    not_ready = 600,
    illegal_address = 700,
    launch_out_of_resources = 701,
    launch_timeout = 702,
    launch_incompatible_texturing = 703,
    peer_access_already_enabled = 704,
    peer_access_not_enabled = 705,
    primary_context_active = 708,
    context_is_destroyed = 709,
    assert = 710,
    too_many_peers = 711,
    host_memory_already_registered = 712,
    host_memory_not_registered = 713,
    hardware_stack_error = 714,
    illegal_instruction = 715,
    misaligned_address = 716,
    invalid_address_space = 717,
    invalid_pc = 718,
    launch_failed = 719,
    cooperative_launch_too_large = 720,
    not_permitted = 800,
    not_supported = 801,
    system_not_ready = 802,
    system_driver_mismatch = 803,
    compat_not_supported_on_device = 804,
    mps_connection_failed = 805,
    mps_rpc_failure = 806,
    mps_server_not_ready = 807,
    mps_max_clients_reached = 808,
    mps_max_connections_reached = 809,
    mps_client_terminated = 810,
    cdp_not_supported = 811,
    cdp_version_mismatch = 812,
    stream_capture_unsupported = 900,
    stream_capture_invalidated = 901,
    stream_capture_merge = 902,
    stream_capture_unmatched = 903,
    stream_capture_unjoined = 904,
    stream_capture_isolation = 905,
    stream_capture_implicit = 906,
    captured_event = 907,
    stream_capture_wrong_thread = 908,
    timeout = 909,
    graph_exec_update_failure = 910,
    external_device = 911,
    invalid_cluster_size = 912,
    function_not_loaded = 913,
    invalid_resource_type = 914,
    invalid_resource_configuration = 915,
    unknown = 999,
    // custom errors
    unsupported_codec = 1001,
    unsupported_resolution = 1002,
unsupported_mbcount = 1003,
};

