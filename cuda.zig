const std = @import("std");

const cuda_bindings = @import("cuda_bindings");

const cuda_log = std.log.scoped(.cuda_log);

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub const load = cuda_bindings.load;

/// Initialize CUDA.
pub fn init() Error!void {
    try result(cuda_bindings.cuInit.?(0));
}

pub const Context = struct {
    inner: cuda_bindings.Context,

    pub fn init(device: Device) Error!Context {
        var context: cuda_bindings.Context = null;
        try result(cuda_bindings.cuCtxCreate_v2.?(&context, 0, device));
        return .{ .inner = context };
    }

    pub fn push(self: Context) Error!void {
        try result(cuda_bindings.cuCtxPushCurrent_v2.?(self.inner));
    }

    pub fn pop(self: Context) Error!void {
        var context: cuda_bindings.Context = null;
        try result(cuda_bindings.cuCtxPopCurrent_v2.?(&context));
        std.debug.assert(context == self.inner);
    }

    pub fn deinit(self: Context) void {
        result(cuda_bindings.cuCtxDestroy_v2.?(self.inner)) catch unreachable;
    }
};

pub const Device = cuda_bindings.Device;

pub const DevicePtr = cuda_bindings.DevicePtr;

pub inline fn allocPitch(
    width: usize,
    height: usize,
    comptime elem_size: enum { element_size_4, element_size_8, element_size_16 },
) Error!struct { ptr: DevicePtr, pitch: usize } {
    var device_ptr: DevicePtr = undefined;
    var pitch: usize = undefined;
    try result(cuda_bindings.cuMemAllocPitch_v2.?(
        &device_ptr,
        &pitch,
        width,
        height,
        comptime switch (elem_size) {
            .element_size_4 => 4,
            .element_size_8 => 8,
            .element_size_16 => 16,
        },
    ));
    return .{ .ptr = device_ptr, .pitch = pitch };
}

pub inline fn free(ptr: DevicePtr) void {
    result(cuda_bindings.cuMemFree_v2.?(ptr)) catch unreachable;
}

pub inline fn copy2D(
    copy: union(enum) {
        host_to_device: struct {
            src: []const u8,
            dst: DevicePtr,
        },
        device_to_host: struct {
            src: DevicePtr,
            dst: []u8,
        },
        device_to_device: struct {
            src: DevicePtr,
            dst: DevicePtr,
        },
    },
    args: struct {
        src_pitch: usize,
        dst_pitch: usize,
        dims: struct {
            width: usize,
            height: usize,
        },
    },
) Error!void {
    std.debug.assert(args.dims.width <= args.src_pitch and args.dims.width <= args.dst_pitch);
    switch (copy) {
        .host_to_device => |copy_args| std.debug.assert(copy_args.src.len == (args.src_pitch * args.dims.height)),
        .device_to_host => |copy_args| std.debug.assert(copy_args.dst.len == (args.dst_pitch * args.dims.height)),
        else => {},
    }
    const params = switch (copy) {
        .host_to_device => |copy_args| cuda_bindings.Memcpy2D{
            .srcXInBytes = 0,
            .srcY = 0,
            .srcMemoryType = cuda_bindings.MemoryType.host,
            .srcHost = copy_args.src.ptr,
            .srcDevice = 0,
            .srcArray = std.mem.zeroes(cuda_bindings.Array),
            .srcPitch = args.src_pitch,
            .dstXInBytes = 0,
            .dstY = 0,
            .dstMemoryType = cuda_bindings.MemoryType.device,
            .dstHost = null,
            .dstDevice = copy_args.dst,
            .dstArray = std.mem.zeroes(cuda_bindings.Array),
            .dstPitch = args.dst_pitch,
            .WidthInBytes = args.dims.width,
            .Height = args.dims.height,
        },
        .device_to_host => |copy_args| cuda_bindings.Memcpy2D{
            .srcXInBytes = 0,
            .srcY = 0,
            .srcMemoryType = cuda_bindings.MemoryType.device,
            .srcHost = null,
            .srcDevice = copy_args.src,
            .srcArray = std.mem.zeroes(cuda_bindings.Array),
            .srcPitch = args.src_pitch,
            .dstXInBytes = 0,
            .dstY = 0,
            .dstMemoryType = cuda_bindings.MemoryType.host,
            .dstHost = copy_args.dst.ptr,
            .dstDevice = 0,
            .dstArray = std.mem.zeroes(cuda_bindings.Array),
            .dstPitch = args.dst_pitch,
            .WidthInBytes = args.dims.width,
            .Height = args.dims.height,
        },
        .device_to_device => |copy_args| cuda_bindings.Memcpy2D{
            .srcXInBytes = 0,
            .srcY = 0,
            .srcMemoryType = cuda_bindings.MemoryType.device,
            .srcHost = null,
            .srcDevice = copy_args.src,
            .srcArray = std.mem.zeroes(cuda_bindings.Array),
            .srcPitch = args.src_pitch,
            .dstXInBytes = 0,
            .dstY = 0,
            .dstMemoryType = cuda_bindings.MemoryType.device,
            .dstHost = null,
            .dstDevice = copy_args.dst,
            .dstArray = std.mem.zeroes(cuda_bindings.Array),
            .dstPitch = args.dst_pitch,
            .WidthInBytes = args.dims.width,
            .Height = args.dims.height,
        },
    };
    try result(cuda_bindings.cuMemcpy2D_v2.?(&params));
}

fn result(ret: cuda_bindings.Result) Error!void {
    switch (ret) {
        .success => return,
        .invalid_value => return error.InvalidValue,
        .out_of_memory => return error.OutOfMemory,
        .not_initialized => return error.NotInitialized,
        .deinitialized => return error.Deinitialized,
        .profiler_disabled => return error.ProfilerDisabled,
        .profiler_not_initialized => return error.ProfilerNotInitialized,
        .profiler_already_started => return error.ProfilerAlreadyStarted,
        .profiler_already_stopped => return error.ProfilerAlreadyStopped,
        .stub_library => return error.StubLibrary,
        .device_unavailable => return error.DeviceUnavailable,
        .no_device => return error.NoDevice,
        .invalid_device => return error.InvalidDevice,
        .device_not_licensed => return error.DeviceNotLicensed,
        .invalid_image => return error.InvalidImage,
        .invalid_context => return error.InvalidContext,
        .context_already_current => return error.ContextAlreadyCurrent,
        .map_failed => return error.MapFailed,
        .unmap_failed => return error.UnmapFailed,
        .array_is_mapped => return error.ArrayIsMapped,
        .already_mapped => return error.AlreadyMapped,
        .no_binary_for_gpu => return error.NoBinaryForGpu,
        .already_acquired => return error.AlreadyAcquired,
        .not_mapped => return error.NotMapped,
        .not_mapped_as_array => return error.NotMappedAsArray,
        .not_mapped_as_pointer => return error.NotMappedAsPointer,
        .ecc_uncorrectable => return error.EccUncorrectable,
        .unsupported_limit => return error.UnsupportedLimit,
        .context_already_in_use => return error.ContextAlreadyInUse,
        .peer_access_unsupported => return error.PeerAccessUnsupported,
        .invalid_ptx => return error.InvalidPtx,
        .invalid_graphics_context => return error.InvalidGraphicsContext,
        .nvlink_uncorrectable => return error.NvlinkUncorrectable,
        .jit_compiler_not_found => return error.JitCompilerNotFound,
        .unsupported_ptx_version => return error.UnsupportedPtxVersion,
        .jit_compilation_disabled => return error.JitCompilationDisabled,
        .unsupported_exec_affinity => return error.UnsupportedExecAffinity,
        .unsupported_devside_sync => return error.UnsupportedDevsideSync,
        .invalid_source => return error.InvalidSource,
        .file_not_found => return error.FileNotFound,
        .shared_object_symbol_not_found => return error.SharedObjectSymbolNotFound,
        .shared_object_init_failed => return error.SharedObjectInitFailed,
        .operating_system => return error.OperatingSystem,
        .invalid_handle => return error.InvalidHandle,
        .illegal_state => return error.IllegalState,
        .lossy_query => return error.LossyQuery,
        .not_found => return error.NotFound,
        .not_ready => return error.NotReady,
        .illegal_address => return error.IllegalAddress,
        .launch_out_of_resources => return error.LaunchOutOfResources,
        .launch_timeout => return error.LaunchTimeout,
        .launch_incompatible_texturing => return error.LaunchIncompatibleTexturing,
        .peer_access_already_enabled => return error.PeerAccessAlreadyEnabled,
        .peer_access_not_enabled => return error.PeerAccessNotEnabled,
        .primary_context_active => return error.PrimaryContextActive,
        .context_is_destroyed => return error.ContextIsDestroyed,
        .assert => return error.Assert,
        .too_many_peers => return error.TooManyPeers,
        .host_memory_already_registered => return error.HostMemoryAlreadyRegistered,
        .host_memory_not_registered => return error.HostMemoryNotRegistered,
        .hardware_stack_error => return error.HardwareStackError,
        .illegal_instruction => return error.IllegalInstruction,
        .misaligned_address => return error.MisalignedAddress,
        .invalid_address_space => return error.InvalidAddressSpace,
        .invalid_pc => return error.InvalidPc,
        .launch_failed => return error.LaunchFailed,
        .cooperative_launch_too_large => return error.CooperativeLaunchTooLarge,
        .not_permitted => return error.NotPermitted,
        .not_supported => return error.NotSupported,
        .system_not_ready => return error.SystemNotReady,
        .system_driver_mismatch => return error.SystemDriverMismatch,
        .compat_not_supported_on_device => return error.CompatNotSupportedOnDevice,
        .mps_connection_failed => return error.MpsConnectionFailed,
        .mps_rpc_failure => return error.MpsRpcFailure,
        .mps_server_not_ready => return error.MpsServerNotReady,
        .mps_max_clients_reached => return error.MpsMaxClientsReached,
        .mps_max_connections_reached => return error.MpsMaxConnectionsReached,
        .mps_client_terminated => return error.MpsClientTerminated,
        .cdp_not_supported => return error.CdpNotSupported,
        .cdp_version_mismatch => return error.CdpVersionMismatch,
        .stream_capture_unsupported => return error.StreamCaptureUnsupported,
        .stream_capture_invalidated => return error.StreamCaptureInvalidated,
        .stream_capture_merge => return error.StreamCaptureMerge,
        .stream_capture_unmatched => return error.StreamCaptureUnmatched,
        .stream_capture_unjoined => return error.StreamCaptureUnjoined,
        .stream_capture_isolation => return error.StreamCaptureIsolation,
        .stream_capture_implicit => return error.StreamCaptureImplicit,
        .captured_event => return error.CapturedEvent,
        .stream_capture_wrong_thread => return error.StreamCaptureWrongThread,
        .timeout => return error.Timeout,
        .graph_exec_update_failure => return error.GraphExecUpdateFailure,
        .external_device => return error.ExternalDevice,
        .invalid_cluster_size => return error.InvalidClusterSize,
        .function_not_loaded => return error.FunctionNotLoaded,
        .invalid_resource_type => return error.InvalidResourceType,
        .invalid_resource_configuration => return error.InvalidResourceConfiguration,
        .unknown => return error.Unknown,
    }
}

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
