pub const enum_CUmemorytype_enum = c_uint;

pub const MemoryType = enum(c_uint) {
    host = 1,
    device = 2,
    array = 3,
    unified = 4,
};

pub const Result = enum(c_uint) {
    success = 0,
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
};

pub const Array = ?*opaque {};
pub const Context = ?*opaque {};
pub const Device = c_int;
pub const DevicePtr = c_ulonglong;
pub const Stream = ?*opaque {};

pub const Memcpy2D = extern struct {
    srcXInBytes: usize,
    srcY: usize,
    srcMemoryType: MemoryType,
    srcHost: ?*const anyopaque,
    srcDevice: DevicePtr,
    srcArray: Array,
    srcPitch: usize,
    dstXInBytes: usize,
    dstY: usize,
    dstMemoryType: MemoryType,
    dstHost: ?*anyopaque,
    dstDevice: DevicePtr,
    dstArray: Array,
    dstPitch: usize,
    WidthInBytes: usize,
    Height: usize,
};

pub var cuInit: ?*const fn (Flags: c_uint) callconv(.C) Result = null;
pub var cuCtxCreate_v2: ?*const fn (pctx: ?*Context, flags: c_uint, dev: Device) callconv(.C) Result = null;
pub var cuCtxDestroy_v2: ?*const fn (ctx: Context) callconv(.C) Result = null;
pub var cuCtxPushCurrent_v2: ?*const fn (ctx: Context) callconv(.C) Result = null;
pub var cuCtxPopCurrent_v2: ?*const fn (pctx: ?*Context) callconv(.C) Result = null;
pub var cuMemAllocPitch_v2: ?*const fn (dptr: *DevicePtr, pPitch: *usize, WidthInBytes: usize, Height: usize, ElementSizeBytes: c_uint) callconv(.C) Result = null;
pub var cuMemFree_v2: ?*const fn (dptr: DevicePtr) callconv(.C) Result = null;
pub var cuMemcpy2D_v2: ?*const fn (pCopy: ?*const Memcpy2D) callconv(.C) Result = null;

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub fn load() !void {
    const std = @import("std");
    const builtin = @import("builtin");

    var cuda = try switch (builtin.target.os.tag) {
        .linux, .macos => std.DynLib.open("libcuda.so.1"),
        .windows => std.DynLib.open("nvcuda.dll"),
        else => @panic("unsupported operating system"),
    };

    cuInit = cuda.lookup(*const fn (Flags: c_uint) callconv(.C) Result, "cuInit") orelse @panic("cuda library invalid");
    cuCtxCreate_v2 = cuda.lookup(*const fn (pctx: [*c]Context, flags: c_uint, dev: Device) callconv(.C) Result, "cuCtxCreate_v2") orelse @panic("cuda library invalid");
    cuCtxDestroy_v2 = cuda.lookup(*const fn (ctx: Context) callconv(.C) Result, "cuCtxDestroy_v2") orelse @panic("cuda library invalid");
    cuCtxPushCurrent_v2 = cuda.lookup(*const fn (ctx: Context) callconv(.C) Result, "cuCtxPushCurrent_v2") orelse @panic("cuda library invalid");
    cuCtxPopCurrent_v2 = cuda.lookup(*const fn (pctx: [*c]Context) callconv(.C) Result, "cuCtxPopCurrent_v2") orelse @panic("cuda library invalid");
    cuMemAllocPitch_v2 = cuda.lookup(*const fn (dptr: *DevicePtr, pPitch: *usize, WidthInBytes: usize, Height: usize, ElementSizeBytes: c_uint) callconv(.C) Result, "cuMemAllocPitch_v2") orelse @panic("cuda library invalid");
    cuMemFree_v2 = cuda.lookup(*const fn (dptr: DevicePtr) callconv(.C) Result, "cuMemFree_v2") orelse @panic("cuda library invalid");
    cuMemcpy2D_v2 = cuda.lookup(*const fn (pCopy: ?*const Memcpy2D) callconv(.C) Result, "cuMemcpy2D_v2") orelse @panic("cuda library invalid");
}
