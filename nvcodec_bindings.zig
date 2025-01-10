//! TODO: explain bindings based on v9.0 since they are binary compat etc etc

// decoder (cuviddec.h, nvcuvid.h)

pub const CUDA_SUCCESS: c_int = 0;
pub const CUDA_ERROR_INVALID_VALUE: c_int = 1;
pub const CUDA_ERROR_OUT_OF_MEMORY: c_int = 2;
pub const CUDA_ERROR_NOT_INITIALIZED: c_int = 3;
pub const CUDA_ERROR_DEINITIALIZED: c_int = 4;
pub const CUDA_ERROR_PROFILER_DISABLED: c_int = 5;
pub const CUDA_ERROR_PROFILER_NOT_INITIALIZED: c_int = 6;
pub const CUDA_ERROR_PROFILER_ALREADY_STARTED: c_int = 7;
pub const CUDA_ERROR_PROFILER_ALREADY_STOPPED: c_int = 8;
pub const CUDA_ERROR_STUB_LIBRARY: c_int = 34;
pub const CUDA_ERROR_DEVICE_UNAVAILABLE: c_int = 46;
pub const CUDA_ERROR_NO_DEVICE: c_int = 100;
pub const CUDA_ERROR_INVALID_DEVICE: c_int = 101;
pub const CUDA_ERROR_DEVICE_NOT_LICENSED: c_int = 102;
pub const CUDA_ERROR_INVALID_IMAGE: c_int = 200;
pub const CUDA_ERROR_INVALID_CONTEXT: c_int = 201;
pub const CUDA_ERROR_CONTEXT_ALREADY_CURRENT: c_int = 202;
pub const CUDA_ERROR_MAP_FAILED: c_int = 205;
pub const CUDA_ERROR_UNMAP_FAILED: c_int = 206;
pub const CUDA_ERROR_ARRAY_IS_MAPPED: c_int = 207;
pub const CUDA_ERROR_ALREADY_MAPPED: c_int = 208;
pub const CUDA_ERROR_NO_BINARY_FOR_GPU: c_int = 209;
pub const CUDA_ERROR_ALREADY_ACQUIRED: c_int = 210;
pub const CUDA_ERROR_NOT_MAPPED: c_int = 211;
pub const CUDA_ERROR_NOT_MAPPED_AS_ARRAY: c_int = 212;
pub const CUDA_ERROR_NOT_MAPPED_AS_POINTER: c_int = 213;
pub const CUDA_ERROR_ECC_UNCORRECTABLE: c_int = 214;
pub const CUDA_ERROR_UNSUPPORTED_LIMIT: c_int = 215;
pub const CUDA_ERROR_CONTEXT_ALREADY_IN_USE: c_int = 216;
pub const CUDA_ERROR_PEER_ACCESS_UNSUPPORTED: c_int = 217;
pub const CUDA_ERROR_INVALID_PTX: c_int = 218;
pub const CUDA_ERROR_INVALID_GRAPHICS_CONTEXT: c_int = 219;
pub const CUDA_ERROR_NVLINK_UNCORRECTABLE: c_int = 220;
pub const CUDA_ERROR_JIT_COMPILER_NOT_FOUND: c_int = 221;
pub const CUDA_ERROR_UNSUPPORTED_PTX_VERSION: c_int = 222;
pub const CUDA_ERROR_JIT_COMPILATION_DISABLED: c_int = 223;
pub const CUDA_ERROR_UNSUPPORTED_EXEC_AFFINITY: c_int = 224;
pub const CUDA_ERROR_UNSUPPORTED_DEVSIDE_SYNC: c_int = 225;
pub const CUDA_ERROR_INVALID_SOURCE: c_int = 300;
pub const CUDA_ERROR_FILE_NOT_FOUND: c_int = 301;
pub const CUDA_ERROR_SHARED_OBJECT_SYMBOL_NOT_FOUND: c_int = 302;
pub const CUDA_ERROR_SHARED_OBJECT_INIT_FAILED: c_int = 303;
pub const CUDA_ERROR_OPERATING_SYSTEM: c_int = 304;
pub const CUDA_ERROR_INVALID_HANDLE: c_int = 400;
pub const CUDA_ERROR_ILLEGAL_STATE: c_int = 401;
pub const CUDA_ERROR_LOSSY_QUERY: c_int = 402;
pub const CUDA_ERROR_NOT_FOUND: c_int = 500;
pub const CUDA_ERROR_NOT_READY: c_int = 600;
pub const CUDA_ERROR_ILLEGAL_ADDRESS: c_int = 700;
pub const CUDA_ERROR_LAUNCH_OUT_OF_RESOURCES: c_int = 701;
pub const CUDA_ERROR_LAUNCH_TIMEOUT: c_int = 702;
pub const CUDA_ERROR_LAUNCH_INCOMPATIBLE_TEXTURING: c_int = 703;
pub const CUDA_ERROR_PEER_ACCESS_ALREADY_ENABLED: c_int = 704;
pub const CUDA_ERROR_PEER_ACCESS_NOT_ENABLED: c_int = 705;
pub const CUDA_ERROR_PRIMARY_CONTEXT_ACTIVE: c_int = 708;
pub const CUDA_ERROR_CONTEXT_IS_DESTROYED: c_int = 709;
pub const CUDA_ERROR_ASSERT: c_int = 710;
pub const CUDA_ERROR_TOO_MANY_PEERS: c_int = 711;
pub const CUDA_ERROR_HOST_MEMORY_ALREADY_REGISTERED: c_int = 712;
pub const CUDA_ERROR_HOST_MEMORY_NOT_REGISTERED: c_int = 713;
pub const CUDA_ERROR_HARDWARE_STACK_ERROR: c_int = 714;
pub const CUDA_ERROR_ILLEGAL_INSTRUCTION: c_int = 715;
pub const CUDA_ERROR_MISALIGNED_ADDRESS: c_int = 716;
pub const CUDA_ERROR_INVALID_ADDRESS_SPACE: c_int = 717;
pub const CUDA_ERROR_INVALID_PC: c_int = 718;
pub const CUDA_ERROR_LAUNCH_FAILED: c_int = 719;
pub const CUDA_ERROR_COOPERATIVE_LAUNCH_TOO_LARGE: c_int = 720;
pub const CUDA_ERROR_NOT_PERMITTED: c_int = 800;
pub const CUDA_ERROR_NOT_SUPPORTED: c_int = 801;
pub const CUDA_ERROR_SYSTEM_NOT_READY: c_int = 802;
pub const CUDA_ERROR_SYSTEM_DRIVER_MISMATCH: c_int = 803;
pub const CUDA_ERROR_COMPAT_NOT_SUPPORTED_ON_DEVICE: c_int = 804;
pub const CUDA_ERROR_MPS_CONNECTION_FAILED: c_int = 805;
pub const CUDA_ERROR_MPS_RPC_FAILURE: c_int = 806;
pub const CUDA_ERROR_MPS_SERVER_NOT_READY: c_int = 807;
pub const CUDA_ERROR_MPS_MAX_CLIENTS_REACHED: c_int = 808;
pub const CUDA_ERROR_MPS_MAX_CONNECTIONS_REACHED: c_int = 809;
pub const CUDA_ERROR_MPS_CLIENT_TERMINATED: c_int = 810;
pub const CUDA_ERROR_CDP_NOT_SUPPORTED: c_int = 811;
pub const CUDA_ERROR_CDP_VERSION_MISMATCH: c_int = 812;
pub const CUDA_ERROR_STREAM_CAPTURE_UNSUPPORTED: c_int = 900;
pub const CUDA_ERROR_STREAM_CAPTURE_INVALIDATED: c_int = 901;
pub const CUDA_ERROR_STREAM_CAPTURE_MERGE: c_int = 902;
pub const CUDA_ERROR_STREAM_CAPTURE_UNMATCHED: c_int = 903;
pub const CUDA_ERROR_STREAM_CAPTURE_UNJOINED: c_int = 904;
pub const CUDA_ERROR_STREAM_CAPTURE_ISOLATION: c_int = 905;
pub const CUDA_ERROR_STREAM_CAPTURE_IMPLICIT: c_int = 906;
pub const CUDA_ERROR_CAPTURED_EVENT: c_int = 907;
pub const CUDA_ERROR_STREAM_CAPTURE_WRONG_THREAD: c_int = 908;
pub const CUDA_ERROR_TIMEOUT: c_int = 909;
pub const CUDA_ERROR_GRAPH_EXEC_UPDATE_FAILURE: c_int = 910;
pub const CUDA_ERROR_EXTERNAL_DEVICE: c_int = 911;
pub const CUDA_ERROR_INVALID_CLUSTER_SIZE: c_int = 912;
pub const CUDA_ERROR_FUNCTION_NOT_LOADED: c_int = 913;
pub const CUDA_ERROR_INVALID_RESOURCE_TYPE: c_int = 914;
pub const CUDA_ERROR_INVALID_RESOURCE_CONFIGURATION: c_int = 915;
pub const CUDA_ERROR_UNKNOWN: c_int = 999;
pub const enum_cudaError_enum = c_uint;
pub const CUresult = enum_cudaError_enum;
pub const CUvideodecoder = ?*anyopaque;
pub const CUvideoctxlock = ?*anyopaque;

pub const cudaVideoCodec_MPEG1: c_int = 0;
pub const cudaVideoCodec_MPEG2: c_int = 1;
pub const cudaVideoCodec_MPEG4: c_int = 2;
pub const cudaVideoCodec_VC1: c_int = 3;
pub const cudaVideoCodec_H264: c_int = 4;
pub const cudaVideoCodec_JPEG: c_int = 5;
pub const cudaVideoCodec_H264_SVC: c_int = 6;
pub const cudaVideoCodec_H264_MVC: c_int = 7;
pub const cudaVideoCodec_HEVC: c_int = 8;
pub const cudaVideoCodec_VP8: c_int = 9;
pub const cudaVideoCodec_VP9: c_int = 10;
pub const cudaVideoCodec_NumCodecs: c_int = 11;
pub const cudaVideoCodec_YUV420: c_int = 1230591318;
pub const cudaVideoCodec_YV12: c_int = 1498820914;
pub const cudaVideoCodec_NV12: c_int = 1314271538;
pub const cudaVideoCodec_YUYV: c_int = 1498765654;
pub const cudaVideoCodec_UYVY: c_int = 1431918169;
pub const enum_cudaVideoCodec_enum = c_uint;

pub const cudaVideoChromaFormat_Monochrome: c_int = 0;
pub const cudaVideoChromaFormat_420: c_int = 1;
pub const cudaVideoChromaFormat_422: c_int = 2;
pub const cudaVideoChromaFormat_444: c_int = 3;
pub const enum_cudaVideoChromaFormat_enum = c_uint;
pub const cudaVideoChromaFormat = enum_cudaVideoChromaFormat_enum;

pub const struct__CUVIDDECODECAPS = extern struct {
    eCodecType: cudaVideoCodec = @import("std").mem.zeroes(cudaVideoCodec),
    eChromaFormat: cudaVideoChromaFormat = @import("std").mem.zeroes(cudaVideoChromaFormat),
    nBitDepthMinus8: c_uint = @import("std").mem.zeroes(c_uint),
    reserved1: [3]c_uint = @import("std").mem.zeroes([3]c_uint),
    bIsSupported: u8 = @import("std").mem.zeroes(u8),
    reserved2: u8 = @import("std").mem.zeroes(u8),
    nOutputFormatMask: c_ushort = @import("std").mem.zeroes(c_ushort),
    nMaxWidth: c_uint = @import("std").mem.zeroes(c_uint),
    nMaxHeight: c_uint = @import("std").mem.zeroes(c_uint),
    nMaxMBCount: c_uint = @import("std").mem.zeroes(c_uint),
    nMinWidth: c_ushort = @import("std").mem.zeroes(c_ushort),
    nMinHeight: c_ushort = @import("std").mem.zeroes(c_ushort),
    reserved3: [11]c_uint = @import("std").mem.zeroes([11]c_uint),
};

pub const struct__CUVIDPROCPARAMS = extern struct {
    progressive_frame: c_int = @import("std").mem.zeroes(c_int),
    second_field: c_int = @import("std").mem.zeroes(c_int),
    top_field_first: c_int = @import("std").mem.zeroes(c_int),
    unpaired_field: c_int = @import("std").mem.zeroes(c_int),
    reserved_flags: c_uint = @import("std").mem.zeroes(c_uint),
    reserved_zero: c_uint = @import("std").mem.zeroes(c_uint),
    raw_input_dptr: c_ulonglong = @import("std").mem.zeroes(c_ulonglong),
    raw_input_pitch: c_uint = @import("std").mem.zeroes(c_uint),
    raw_input_format: c_uint = @import("std").mem.zeroes(c_uint),
    raw_output_dptr: c_ulonglong = @import("std").mem.zeroes(c_ulonglong),
    raw_output_pitch: c_uint = @import("std").mem.zeroes(c_uint),
    Reserved1: c_uint = @import("std").mem.zeroes(c_uint),
    output_stream: CUstream = @import("std").mem.zeroes(CUstream),
    Reserved: [46]c_uint = @import("std").mem.zeroes([46]c_uint),
    Reserved2: [2]?*anyopaque = @import("std").mem.zeroes([2]?*anyopaque),
};

pub const cuvidDecodeStatus_Invalid: c_int = 0;
pub const cuvidDecodeStatus_InProgress: c_int = 1;
pub const cuvidDecodeStatus_Success: c_int = 2;
pub const cuvidDecodeStatus_Error: c_int = 8;
pub const cuvidDecodeStatus_Error_Concealed: c_int = 9;
pub const enum_cuvidDecodeStatus_enum = c_uint;

pub const struct__CUVIDGETDECODESTATUS = extern struct {
    decodeStatus: cuvidDecodeStatus = @import("std").mem.zeroes(cuvidDecodeStatus),
    reserved: [31]c_uint = @import("std").mem.zeroes([31]c_uint),
    pReserved: [8]?*anyopaque = @import("std").mem.zeroes([8]?*anyopaque),
};

pub extern fn cuvidGetDecoderCaps(pdc: [*c]CUVIDDECODECAPS) CUresult;

pub extern fn cuvidCreateDecoder(phDecoder: [*c]CUvideodecoder, pdci: [*c]CUVIDDECODECREATEINFO) CUresult;
pub extern fn cuvidDestroyDecoder(hDecoder: CUvideodecoder) CUresult;
pub extern fn cuvidDecodePicture(hDecoder: CUvideodecoder, pPicParams: ?*CUVIDPICPARAMS) CUresult;
pub extern fn cuvidGetDecodeStatus(hDecoder: CUvideodecoder, nPicIdx: c_int, pDecodeStatus: [*c]CUVIDGETDECODESTATUS) CUresult;
// pub extern fn cuvidReconfigureDecoder(hDecoder: CUvideodecoder, pDecReconfigParams: [*c]CUVIDRECONFIGUREDECODERINFO) CUresult;
pub extern fn cuvidMapVideoFrame64(hDecoder: CUvideodecoder, nPicIdx: c_int, pDevPtr: [*c]c_ulonglong, pPitch: [*c]c_uint, pVPP: [*c]CUVIDPROCPARAMS) CUresult;
pub extern fn cuvidUnmapVideoFrame64(hDecoder: CUvideodecoder, DevPtr: c_ulonglong) CUresult;
pub extern fn cuvidCtxLockCreate(pLock: [*c]CUvideoctxlock, ctx: CUcontext) CUresult;
pub extern fn cuvidCtxLockDestroy(lck: CUvideoctxlock) CUresult;
pub extern fn cuvidCtxLock(lck: CUvideoctxlock, reserved_flags: c_uint) CUresult;
pub extern fn cuvidCtxUnlock(lck: CUvideoctxlock, reserved_flags: c_uint) CUresult;

// encoder (nvEncodeAPI.h)

pub const NVENCAPI = "";
pub const NVENCAPI_MAJOR_VERSION = @as(c_int, 9);
pub const NVENCAPI_MINOR_VERSION = @as(c_int, 1);
pub const NVENCAPI_VERSION = NVENCAPI_MAJOR_VERSION | (NVENCAPI_MINOR_VERSION << @as(c_int, 24));

pub const NV_ENC_SUCCESS: c_int = 0;
pub const NV_ENC_ERR_NO_ENCODE_DEVICE: c_int = 1;
pub const NV_ENC_ERR_UNSUPPORTED_DEVICE: c_int = 2;
pub const NV_ENC_ERR_INVALID_ENCODERDEVICE: c_int = 3;
pub const NV_ENC_ERR_INVALID_DEVICE: c_int = 4;
pub const NV_ENC_ERR_DEVICE_NOT_EXIST: c_int = 5;
pub const NV_ENC_ERR_INVALID_PTR: c_int = 6;
pub const NV_ENC_ERR_INVALID_EVENT: c_int = 7;
pub const NV_ENC_ERR_INVALID_PARAM: c_int = 8;
pub const NV_ENC_ERR_INVALID_CALL: c_int = 9;
pub const NV_ENC_ERR_OUT_OF_MEMORY: c_int = 10;
pub const NV_ENC_ERR_ENCODER_NOT_INITIALIZED: c_int = 11;
pub const NV_ENC_ERR_UNSUPPORTED_PARAM: c_int = 12;
pub const NV_ENC_ERR_LOCK_BUSY: c_int = 13;
pub const NV_ENC_ERR_NOT_ENOUGH_BUFFER: c_int = 14;
pub const NV_ENC_ERR_INVALID_VERSION: c_int = 15;
pub const NV_ENC_ERR_MAP_FAILED: c_int = 16;
pub const NV_ENC_ERR_NEED_MORE_INPUT: c_int = 17;
pub const NV_ENC_ERR_ENCODER_BUSY: c_int = 18;
pub const NV_ENC_ERR_EVENT_NOT_REGISTERD: c_int = 19;
pub const NV_ENC_ERR_GENERIC: c_int = 20;
pub const NV_ENC_ERR_INCOMPATIBLE_CLIENT_KEY: c_int = 21;
pub const NV_ENC_ERR_UNIMPLEMENTED: c_int = 22;
pub const NV_ENC_ERR_RESOURCE_REGISTER_FAILED: c_int = 23;
pub const NV_ENC_ERR_RESOURCE_NOT_REGISTERED: c_int = 24;
pub const NV_ENC_ERR_RESOURCE_NOT_MAPPED: c_int = 25;
pub const enum__NVENCSTATUS = c_uint;
pub const NVENCSTATUS = enum__NVENCSTATUS;

pub const GUID = extern struct {
    Data1: u32 = @import("std").mem.zeroes(u32),
    Data2: u16 = @import("std").mem.zeroes(u16),
    Data3: u16 = @import("std").mem.zeroes(u16),
    Data4: [8]u8 = @import("std").mem.zeroes([8]u8),
};

// I think we can just leave these out?
// pub extern fn NvEncOpenEncodeSession(device: ?*anyopaque, deviceType: u32, encoder: [*c]?*anyopaque) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeGUIDCount(encoder: ?*anyopaque, encodeGUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeGUIDs(encoder: ?*anyopaque, GUIDs: [*c]GUID, guidArraySize: u32, GUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeProfileGUIDCount(encoder: ?*anyopaque, encodeGUID: GUID, encodeProfileGUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeProfileGUIDs(encoder: ?*anyopaque, encodeGUID: GUID, profileGUIDs: [*c]GUID, guidArraySize: u32, GUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetInputFormatCount(encoder: ?*anyopaque, encodeGUID: GUID, inputFmtCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetInputFormats(encoder: ?*anyopaque, encodeGUID: GUID, inputFmts: [*c]NV_ENC_BUFFER_FORMAT, inputFmtArraySize: u32, inputFmtCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeCaps(encoder: ?*anyopaque, encodeGUID: GUID, capsParam: [*c]NV_ENC_CAPS_PARAM, capsVal: [*c]c_int) NVENCSTATUS;
// // pub extern fn NvEncGetEncodePresetCount(encoder: ?*anyopaque, encodeGUID: GUID, encodePresetGUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodePresetGUIDs(encoder: ?*anyopaque, encodeGUID: GUID, presetGUIDs: [*c]GUID, guidArraySize: u32, encodePresetGUIDCount: [*c]u32) NVENCSTATUS;
// // pub extern fn NvEncGetEncodePresetConfig(encoder: ?*anyopaque, encodeGUID: GUID, presetGUID: GUID, presetConfig: ?*NV_ENC_PRESET_CONFIG) NVENCSTATUS;
// pub extern fn NvEncInitializeEncoder(encoder: ?*anyopaque, createEncodeParams: ?*NV_ENC_INITIALIZE_PARAMS) NVENCSTATUS;
// pub extern fn NvEncCreateInputBuffer(encoder: ?*anyopaque, createInputBufferParams: [*c]NV_ENC_CREATE_INPUT_BUFFER) NVENCSTATUS;
// pub extern fn NvEncDestroyInputBuffer(encoder: ?*anyopaque, inputBuffer: NV_ENC_INPUT_PTR) NVENCSTATUS;
// pub extern fn NvEncSetIOCudaStreams(encoder: ?*anyopaque, inputStream: NV_ENC_CUSTREAM_PTR, outputStream: NV_ENC_CUSTREAM_PTR) NVENCSTATUS;
// pub extern fn NvEncCreateBitstreamBuffer(encoder: ?*anyopaque, createBitstreamBufferParams: [*c]NV_ENC_CREATE_BITSTREAM_BUFFER) NVENCSTATUS;
// pub extern fn NvEncDestroyBitstreamBuffer(encoder: ?*anyopaque, bitstreamBuffer: NV_ENC_OUTPUT_PTR) NVENCSTATUS;
// pub extern fn NvEncEncodePicture(encoder: ?*anyopaque, encodePicParams: ?*NV_ENC_PIC_PARAMS) NVENCSTATUS;
// pub extern fn NvEncLockBitstream(encoder: ?*anyopaque, lockBitstreamBufferParams: ?*NV_ENC_LOCK_BITSTREAM) NVENCSTATUS;
// pub extern fn NvEncUnlockBitstream(encoder: ?*anyopaque, bitstreamBuffer: NV_ENC_OUTPUT_PTR) NVENCSTATUS;
// pub extern fn NvEncLockInputBuffer(encoder: ?*anyopaque, lockInputBufferParams: ?*NV_ENC_LOCK_INPUT_BUFFER) NVENCSTATUS;
// pub extern fn NvEncUnlockInputBuffer(encoder: ?*anyopaque, inputBuffer: NV_ENC_INPUT_PTR) NVENCSTATUS;
// // pub extern fn NvEncGetEncodeStats(encoder: ?*anyopaque, encodeStats: [*c]NV_ENC_STAT) NVENCSTATUS;
// pub extern fn NvEncGetSequenceParams(encoder: ?*anyopaque, sequenceParamPayload: [*c]NV_ENC_SEQUENCE_PARAM_PAYLOAD) NVENCSTATUS;
// // pub extern fn NvEncRegisterAsyncEvent(encoder: ?*anyopaque, eventParams: [*c]NV_ENC_EVENT_PARAMS) NVENCSTATUS;
// // pub extern fn NvEncUnregisterAsyncEvent(encoder: ?*anyopaque, eventParams: [*c]NV_ENC_EVENT_PARAMS) NVENCSTATUS;
// // pub extern fn NvEncMapInputResource(encoder: ?*anyopaque, mapInputResParams: [*c]NV_ENC_MAP_INPUT_RESOURCE) NVENCSTATUS;
// // pub extern fn NvEncUnmapInputResource(encoder: ?*anyopaque, mappedInputBuffer: NV_ENC_INPUT_PTR) NVENCSTATUS;
// pub extern fn NvEncDestroyEncoder(encoder: ?*anyopaque) NVENCSTATUS;
// // pub extern fn NvEncInvalidateRefFrames(encoder: ?*anyopaque, invalidRefFrameTimeStamp: u64) NVENCSTATUS;
// // pub extern fn NvEncRegisterResource(encoder: ?*anyopaque, registerResParams: [*c]NV_ENC_REGISTER_RESOURCE) NVENCSTATUS;
// // pub extern fn NvEncUnregisterResource(encoder: ?*anyopaque, registeredResource: NV_ENC_REGISTERED_PTR) NVENCSTATUS;
// // pub extern fn NvEncReconfigureEncoder(encoder: ?*anyopaque, reInitEncodeParams: ?*NV_ENC_RECONFIGURE_PARAMS) NVENCSTATUS;
// // pub extern fn NvEncCreateMVBuffer(encoder: ?*anyopaque, createMVBufferParams: [*c]NV_ENC_CREATE_MV_BUFFER) NVENCSTATUS;
// // pub extern fn NvEncDestroyMVBuffer(encoder: ?*anyopaque, mvBuffer: NV_ENC_OUTPUT_PTR) NVENCSTATUS;
// // pub extern fn NvEncRunMotionEstimationOnly(encoder: ?*anyopaque, meOnlyParams: [*c]NV_ENC_MEONLY_PARAMS) NVENCSTATUS;
// // pub extern fn NvEncodeAPIGetMaxSupportedVersion(version: [*c]u32) NVENCSTATUS;
// pub extern fn NvEncGetLastErrorString(encoder: ?*anyopaque) [*c]const u8;

pub const NV_ENC_PARAMS_FRAME_FIELD_MODE_FRAME: c_int = 1;
pub const NV_ENC_PARAMS_FRAME_FIELD_MODE_FIELD: c_int = 2;
pub const NV_ENC_PARAMS_FRAME_FIELD_MODE_MBAFF: c_int = 3;
pub const enum__NV_ENC_PARAMS_FRAME_FIELD_MODE = c_uint;
pub const NV_ENC_PARAMS_FRAME_FIELD_MODE = enum__NV_ENC_PARAMS_FRAME_FIELD_MODE;

pub const NV_ENC_MV_PRECISION_DEFAULT: c_int = 0;
pub const NV_ENC_MV_PRECISION_FULL_PEL: c_int = 1;
pub const NV_ENC_MV_PRECISION_HALF_PEL: c_int = 2;
pub const NV_ENC_MV_PRECISION_QUARTER_PEL: c_int = 3;
pub const enum__NV_ENC_MV_PRECISION = c_uint;
pub const NV_ENC_MV_PRECISION = enum__NV_ENC_MV_PRECISION;

pub const struct__NV_ENC_CONFIG_H264_VUI_PARAMETERS = extern struct {
    overscanInfoPresentFlag: u32 = @import("std").mem.zeroes(u32),
    overscanInfo: u32 = @import("std").mem.zeroes(u32),
    videoSignalTypePresentFlag: u32 = @import("std").mem.zeroes(u32),
    videoFormat: u32 = @import("std").mem.zeroes(u32),
    videoFullRangeFlag: u32 = @import("std").mem.zeroes(u32),
    colourDescriptionPresentFlag: u32 = @import("std").mem.zeroes(u32),
    colourPrimaries: u32 = @import("std").mem.zeroes(u32),
    transferCharacteristics: u32 = @import("std").mem.zeroes(u32),
    colourMatrix: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationFlag: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationTop: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationBot: u32 = @import("std").mem.zeroes(u32),
    bitstreamRestrictionFlag: u32 = @import("std").mem.zeroes(u32),
    reserved: [15]u32 = @import("std").mem.zeroes([15]u32),
};

pub const struct__NV_ENC_CONFIG_H264_VUI_PARAMETERS = extern struct {
    overscanInfoPresentFlag: u32 = @import("std").mem.zeroes(u32),
    overscanInfo: u32 = @import("std").mem.zeroes(u32),
    videoSignalTypePresentFlag: u32 = @import("std").mem.zeroes(u32),
    videoFormat: u32 = @import("std").mem.zeroes(u32),
    videoFullRangeFlag: u32 = @import("std").mem.zeroes(u32),
    colourDescriptionPresentFlag: u32 = @import("std").mem.zeroes(u32),
    colourPrimaries: u32 = @import("std").mem.zeroes(u32),
    transferCharacteristics: u32 = @import("std").mem.zeroes(u32),
    colourMatrix: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationFlag: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationTop: u32 = @import("std").mem.zeroes(u32),
    chromaSampleLocationBot: u32 = @import("std").mem.zeroes(u32),
    bitstreamRestrictionFlag: u32 = @import("std").mem.zeroes(u32),
    reserved: [15]u32 = @import("std").mem.zeroes([15]u32),
};

pub const NV_ENC_H264_ENTROPY_CODING_MODE_AUTOSELECT: c_int = 0;
pub const NV_ENC_H264_ENTROPY_CODING_MODE_CABAC: c_int = 1;
pub const NV_ENC_H264_ENTROPY_CODING_MODE_CAVLC: c_int = 2;
pub const enum__NV_ENC_H264_ENTROPY_CODING_MODE = c_uint;
pub const NV_ENC_H264_ENTROPY_CODING_MODE = enum__NV_ENC_H264_ENTROPY_CODING_MODE;

pub const NV_ENC_H264_BDIRECT_MODE_AUTOSELECT: c_int = 0;
pub const NV_ENC_H264_BDIRECT_MODE_DISABLE: c_int = 1;
pub const NV_ENC_H264_BDIRECT_MODE_TEMPORAL: c_int = 2;
pub const NV_ENC_H264_BDIRECT_MODE_SPATIAL: c_int = 3;
pub const enum__NV_ENC_H264_BDIRECT_MODE = c_uint;
pub const NV_ENC_H264_BDIRECT_MODE = enum__NV_ENC_H264_BDIRECT_MODE;

pub const NV_ENC_H264_FMO_AUTOSELECT: c_int = 0;
pub const NV_ENC_H264_FMO_ENABLE: c_int = 1;
pub const NV_ENC_H264_FMO_DISABLE: c_int = 2;
pub const enum__NV_ENC_H264_FMO_MODE = c_uint;
pub const NV_ENC_H264_FMO_MODE = enum__NV_ENC_H264_FMO_MODE;

pub const NV_ENC_H264_ADAPTIVE_TRANSFORM_AUTOSELECT: c_int = 0;
pub const NV_ENC_H264_ADAPTIVE_TRANSFORM_DISABLE: c_int = 1;
pub const NV_ENC_H264_ADAPTIVE_TRANSFORM_ENABLE: c_int = 2;
pub const enum__NV_ENC_H264_ADAPTIVE_TRANSFORM_MODE = c_uint;
pub const NV_ENC_H264_ADAPTIVE_TRANSFORM_MODE = enum__NV_ENC_H264_ADAPTIVE_TRANSFORM_MODE;

pub const NV_ENC_STEREO_PACKING_MODE_NONE: c_int = 0;
pub const NV_ENC_STEREO_PACKING_MODE_CHECKERBOARD: c_int = 1;
pub const NV_ENC_STEREO_PACKING_MODE_COLINTERLEAVE: c_int = 2;
pub const NV_ENC_STEREO_PACKING_MODE_ROWINTERLEAVE: c_int = 3;
pub const NV_ENC_STEREO_PACKING_MODE_SIDEBYSIDE: c_int = 4;
pub const NV_ENC_STEREO_PACKING_MODE_TOPBOTTOM: c_int = 5;
pub const NV_ENC_STEREO_PACKING_MODE_FRAMESEQ: c_int = 6;
pub const enum__NV_ENC_STEREO_PACKING_MODE = c_uint;
pub const NV_ENC_STEREO_PACKING_MODE = enum__NV_ENC_STEREO_PACKING_MODE;

pub const struct__NV_ENC_CONFIG_H264 = extern struct {
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    level: u32 = @import("std").mem.zeroes(u32),
    idrPeriod: u32 = @import("std").mem.zeroes(u32),
    separateColourPlaneFlag: u32 = @import("std").mem.zeroes(u32),
    disableDeblockingFilterIDC: u32 = @import("std").mem.zeroes(u32),
    numTemporalLayers: u32 = @import("std").mem.zeroes(u32),
    spsId: u32 = @import("std").mem.zeroes(u32),
    ppsId: u32 = @import("std").mem.zeroes(u32),
    adaptiveTransformMode: NV_ENC_H264_ADAPTIVE_TRANSFORM_MODE = @import("std").mem.zeroes(NV_ENC_H264_ADAPTIVE_TRANSFORM_MODE),
    fmoMode: NV_ENC_H264_FMO_MODE = @import("std").mem.zeroes(NV_ENC_H264_FMO_MODE),
    bdirectMode: NV_ENC_H264_BDIRECT_MODE = @import("std").mem.zeroes(NV_ENC_H264_BDIRECT_MODE),
    entropyCodingMode: NV_ENC_H264_ENTROPY_CODING_MODE = @import("std").mem.zeroes(NV_ENC_H264_ENTROPY_CODING_MODE),
    stereoMode: NV_ENC_STEREO_PACKING_MODE = @import("std").mem.zeroes(NV_ENC_STEREO_PACKING_MODE),
    intraRefreshPeriod: u32 = @import("std").mem.zeroes(u32),
    intraRefreshCnt: u32 = @import("std").mem.zeroes(u32),
    maxNumRefFrames: u32 = @import("std").mem.zeroes(u32),
    sliceMode: u32 = @import("std").mem.zeroes(u32),
    sliceModeData: u32 = @import("std").mem.zeroes(u32),
    h264VUIParameters: NV_ENC_CONFIG_H264_VUI_PARAMETERS = @import("std").mem.zeroes(NV_ENC_CONFIG_H264_VUI_PARAMETERS),
    ltrNumFrames: u32 = @import("std").mem.zeroes(u32),
    ltrTrustMode: u32 = @import("std").mem.zeroes(u32),
    chromaFormatIDC: u32 = @import("std").mem.zeroes(u32),
    maxTemporalLayers: u32 = @import("std").mem.zeroes(u32),
    useBFramesAsRef: NV_ENC_BFRAME_REF_MODE = @import("std").mem.zeroes(NV_ENC_BFRAME_REF_MODE),
    reserved1: [269]u32 = @import("std").mem.zeroes([269]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const NV_ENC_HEVC_CUSIZE_AUTOSELECT: c_int = 0;
pub const NV_ENC_HEVC_CUSIZE_8x8: c_int = 1;
pub const NV_ENC_HEVC_CUSIZE_16x16: c_int = 2;
pub const NV_ENC_HEVC_CUSIZE_32x32: c_int = 3;
pub const NV_ENC_HEVC_CUSIZE_64x64: c_int = 4;
pub const enum__NV_ENC_HEVC_CUSIZE = c_uint;
pub const NV_ENC_HEVC_CUSIZE = enum__NV_ENC_HEVC_CUSIZE;

pub const NV_ENC_CONFIG_HEVC_VUI_PARAMETERS = NV_ENC_CONFIG_H264_VUI_PARAMETERS; // TODO this is the same struct

pub const NV_ENC_BFRAME_REF_MODE_DISABLED: c_int = 0;
pub const NV_ENC_BFRAME_REF_MODE_EACH: c_int = 1;
pub const NV_ENC_BFRAME_REF_MODE_MIDDLE: c_int = 2;
pub const enum__NV_ENC_BFRAME_REF_MODE = c_uint;
pub const NV_ENC_BFRAME_REF_MODE = enum__NV_ENC_BFRAME_REF_MODE;

pub const struct__NV_ENC_CONFIG_HEVC = extern struct {
    level: u32 = @import("std").mem.zeroes(u32),
    tier: u32 = @import("std").mem.zeroes(u32),
    minCUSize: NV_ENC_HEVC_CUSIZE = @import("std").mem.zeroes(NV_ENC_HEVC_CUSIZE),
    maxCUSize: NV_ENC_HEVC_CUSIZE = @import("std").mem.zeroes(NV_ENC_HEVC_CUSIZE),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    idrPeriod: u32 = @import("std").mem.zeroes(u32),
    intraRefreshPeriod: u32 = @import("std").mem.zeroes(u32),
    intraRefreshCnt: u32 = @import("std").mem.zeroes(u32),
    maxNumRefFramesInDPB: u32 = @import("std").mem.zeroes(u32),
    ltrNumFrames: u32 = @import("std").mem.zeroes(u32),
    vpsId: u32 = @import("std").mem.zeroes(u32),
    spsId: u32 = @import("std").mem.zeroes(u32),
    ppsId: u32 = @import("std").mem.zeroes(u32),
    sliceMode: u32 = @import("std").mem.zeroes(u32),
    sliceModeData: u32 = @import("std").mem.zeroes(u32),
    maxTemporalLayersMinus1: u32 = @import("std").mem.zeroes(u32),
    hevcVUIParameters: NV_ENC_CONFIG_HEVC_VUI_PARAMETERS = @import("std").mem.zeroes(NV_ENC_CONFIG_HEVC_VUI_PARAMETERS),
    ltrTrustMode: u32 = @import("std").mem.zeroes(u32),
    useBFramesAsRef: NV_ENC_BFRAME_REF_MODE = @import("std").mem.zeroes(NV_ENC_BFRAME_REF_MODE),
    reserved1: [216]u32 = @import("std").mem.zeroes([216]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const struct__NV_ENC_CONFIG_H264_MEONLY = extern struct {
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    reserved1: [255]u32 = @import("std").mem.zeroes([255]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const struct__NV_ENC_CONFIG_HEVC_MEONLY = extern struct {
    reserved: [256]u32 = @import("std").mem.zeroes([256]u32),
    reserved1: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const union__NV_ENC_CODEC_CONFIG = extern union {
    h264Config: NV_ENC_CONFIG_H264,
    hevcConfig: NV_ENC_CONFIG_HEVC,
    h264MeOnlyConfig: NV_ENC_CONFIG_H264_MEONLY,
    hevcMeOnlyConfig: NV_ENC_CONFIG_HEVC_MEONLY,
    reserved: [320]u32,
};

pub const NV_ENC_PARAMS_RC_CONSTQP: c_int = 0;
pub const NV_ENC_PARAMS_RC_VBR: c_int = 1;
pub const NV_ENC_PARAMS_RC_CBR: c_int = 2;
pub const NV_ENC_PARAMS_RC_CBR_LOWDELAY_HQ: c_int = 8;
pub const NV_ENC_PARAMS_RC_CBR_HQ: c_int = 16;
pub const NV_ENC_PARAMS_RC_VBR_HQ: c_int = 32;
pub const enum__NV_ENC_PARAMS_RC_MODE = c_uint;
pub const NV_ENC_PARAMS_RC_MODE = enum__NV_ENC_PARAMS_RC_MODE;

// TODO this is similar to the other enum but different vals
// not sure what to do with it
pub const NV_ENC_PARAMS_RC_VBR_MINQP = @import("std").zig.c_translation.cast(NV_ENC_PARAMS_RC_MODE, @as(c_int, 0x4));
pub const NV_ENC_PARAMS_RC_2_PASS_QUALITY = NV_ENC_PARAMS_RC_CBR_LOWDELAY_HQ;
pub const NV_ENC_PARAMS_RC_2_PASS_FRAMESIZE_CAP = NV_ENC_PARAMS_RC_CBR_HQ;
pub const NV_ENC_PARAMS_RC_2_PASS_VBR = NV_ENC_PARAMS_RC_VBR_HQ;
pub const NV_ENC_PARAMS_RC_CBR2 = NV_ENC_PARAMS_RC_CBR;

pub const struct__NV_ENC_QP = extern struct {
    qpInterP: u32 = @import("std").mem.zeroes(u32),
    qpInterB: u32 = @import("std").mem.zeroes(u32),
    qpIntra: u32 = @import("std").mem.zeroes(u32),
};

pub const NV_ENC_QP_MAP_DISABLED: c_int = 0;
pub const NV_ENC_QP_MAP_EMPHASIS: c_int = 1;
pub const NV_ENC_QP_MAP_DELTA: c_int = 2;
pub const NV_ENC_QP_MAP: c_int = 3;
pub const enum__NV_ENC_QP_MAP_MODE = c_uint;
pub const NV_ENC_QP_MAP_MODE = enum__NV_ENC_QP_MAP_MODE;

pub const struct__NV_ENC_RC_PARAMS = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    rateControlMode: NV_ENC_PARAMS_RC_MODE = @import("std").mem.zeroes(NV_ENC_PARAMS_RC_MODE),
    constQP: NV_ENC_QP = @import("std").mem.zeroes(NV_ENC_QP),
    averageBitRate: u32 = @import("std").mem.zeroes(u32),
    maxBitRate: u32 = @import("std").mem.zeroes(u32),
    vbvBufferSize: u32 = @import("std").mem.zeroes(u32),
    vbvInitialDelay: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    minQP: NV_ENC_QP = @import("std").mem.zeroes(NV_ENC_QP),
    maxQP: NV_ENC_QP = @import("std").mem.zeroes(NV_ENC_QP),
    initialRCQP: NV_ENC_QP = @import("std").mem.zeroes(NV_ENC_QP),
    temporallayerIdxMask: u32 = @import("std").mem.zeroes(u32),
    temporalLayerQP: [8]u8 = @import("std").mem.zeroes([8]u8),
    targetQuality: u8 = @import("std").mem.zeroes(u8),
    targetQualityLSB: u8 = @import("std").mem.zeroes(u8),
    lookaheadDepth: u16 = @import("std").mem.zeroes(u16),
    reserved1: u32 = @import("std").mem.zeroes(u32),
    qpMapMode: NV_ENC_QP_MAP_MODE = @import("std").mem.zeroes(NV_ENC_QP_MAP_MODE),
    reserved: [7]u32 = @import("std").mem.zeroes([7]u32),
};

pub const struct__NV_ENC_CONFIG = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    profileGUID: GUID = @import("std").mem.zeroes(GUID),
    gopLength: u32 = @import("std").mem.zeroes(u32),
    frameIntervalP: i32 = @import("std").mem.zeroes(i32),
    monoChromeEncoding: u32 = @import("std").mem.zeroes(u32),
    frameFieldMode: NV_ENC_PARAMS_FRAME_FIELD_MODE = @import("std").mem.zeroes(NV_ENC_PARAMS_FRAME_FIELD_MODE),
    mvPrecision: NV_ENC_MV_PRECISION = @import("std").mem.zeroes(NV_ENC_MV_PRECISION),
    rcParams: NV_ENC_RC_PARAMS = @import("std").mem.zeroes(NV_ENC_RC_PARAMS),
    encodeCodecConfig: NV_ENC_CODEC_CONFIG = @import("std").mem.zeroes(NV_ENC_CODEC_CONFIG),
    reserved: [278]u32 = @import("std").mem.zeroes([278]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const struct__NV_ENC_INITIALIZE_PARAMS = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    encodeGUID: GUID = @import("std").mem.zeroes(GUID),
    presetGUID: GUID = @import("std").mem.zeroes(GUID),
    encodeWidth: u32 = @import("std").mem.zeroes(u32),
    encodeHeight: u32 = @import("std").mem.zeroes(u32),
    darWidth: u32 = @import("std").mem.zeroes(u32),
    darHeight: u32 = @import("std").mem.zeroes(u32),
    frameRateNum: u32 = @import("std").mem.zeroes(u32),
    frameRateDen: u32 = @import("std").mem.zeroes(u32),
    enableEncodeAsync: u32 = @import("std").mem.zeroes(u32),
    enablePTD: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    privDataSize: u32 = @import("std").mem.zeroes(u32),
    privData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    encodeConfig: ?*NV_ENC_CONFIG = @import("std").mem.zeroes(?*NV_ENC_CONFIG),
    maxEncodeWidth: u32 = @import("std").mem.zeroes(u32),
    maxEncodeHeight: u32 = @import("std").mem.zeroes(u32),
    maxMEHintCountsPerBlock: [2]NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE = @import("std").mem.zeroes([2]NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE),
    reserved: [289]u32 = @import("std").mem.zeroes([289]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const NV_ENC_INPUT_PTR = ?*anyopaque;
pub const NV_ENC_OUTPUT_PTR = ?*anyopaque;

pub const NV_ENC_MEMORY_HEAP_AUTOSELECT: c_int = 0;
pub const NV_ENC_MEMORY_HEAP_VID: c_int = 1;
pub const NV_ENC_MEMORY_HEAP_SYSMEM_CACHED: c_int = 2;
pub const NV_ENC_MEMORY_HEAP_SYSMEM_UNCACHED: c_int = 3;
pub const enum__NV_ENC_MEMORY_HEAP = c_uint;
pub const NV_ENC_MEMORY_HEAP = enum__NV_ENC_MEMORY_HEAP;

pub const struct__NV_ENC_CREATE_INPUT_BUFFER = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    memoryHeap: NV_ENC_MEMORY_HEAP = @import("std").mem.zeroes(NV_ENC_MEMORY_HEAP),
    bufferFmt: NV_ENC_BUFFER_FORMAT = @import("std").mem.zeroes(NV_ENC_BUFFER_FORMAT),
    reserved: u32 = @import("std").mem.zeroes(u32),
    inputBuffer: NV_ENC_INPUT_PTR = @import("std").mem.zeroes(NV_ENC_INPUT_PTR),
    pSysMemBuffer: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    reserved1: [57]u32 = @import("std").mem.zeroes([57]u32),
    reserved2: [63]?*anyopaque = @import("std").mem.zeroes([63]?*anyopaque),
};

pub const struct__NV_ENC_CREATE_BITSTREAM_BUFFER = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    size: u32 = @import("std").mem.zeroes(u32),
    memoryHeap: NV_ENC_MEMORY_HEAP = @import("std").mem.zeroes(NV_ENC_MEMORY_HEAP),
    reserved: u32 = @import("std").mem.zeroes(u32),
    bitstreamBuffer: NV_ENC_OUTPUT_PTR = @import("std").mem.zeroes(NV_ENC_OUTPUT_PTR),
    bitstreamBufferPtr: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    reserved1: [58]u32 = @import("std").mem.zeroes([58]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const NV_ENC_BUFFER_FORMAT_UNDEFINED: c_int = 0;
pub const NV_ENC_BUFFER_FORMAT_NV12: c_int = 1;
pub const NV_ENC_BUFFER_FORMAT_YV12: c_int = 16;
pub const NV_ENC_BUFFER_FORMAT_IYUV: c_int = 256;
pub const NV_ENC_BUFFER_FORMAT_YUV444: c_int = 4096;
pub const NV_ENC_BUFFER_FORMAT_YUV420_10BIT: c_int = 65536;
pub const NV_ENC_BUFFER_FORMAT_YUV444_10BIT: c_int = 1048576;
pub const NV_ENC_BUFFER_FORMAT_ARGB: c_int = 16777216;
pub const NV_ENC_BUFFER_FORMAT_ARGB10: c_int = 33554432;
pub const NV_ENC_BUFFER_FORMAT_AYUV: c_int = 67108864;
pub const NV_ENC_BUFFER_FORMAT_ABGR: c_int = 268435456;
pub const NV_ENC_BUFFER_FORMAT_ABGR10: c_int = 536870912;
pub const NV_ENC_BUFFER_FORMAT_U8: c_int = 1073741824;
pub const enum__NV_ENC_BUFFER_FORMAT = c_uint;
pub const NV_ENC_BUFFER_FORMAT = enum__NV_ENC_BUFFER_FORMAT;

pub const NV_ENC_PIC_STRUCT_FRAME: c_int = 1;
pub const NV_ENC_PIC_STRUCT_FIELD_TOP_BOTTOM: c_int = 2;
pub const NV_ENC_PIC_STRUCT_FIELD_BOTTOM_TOP: c_int = 3;
pub const enum__NV_ENC_PIC_STRUCT = c_uint;
pub const NV_ENC_PIC_STRUCT = enum__NV_ENC_PIC_STRUCT;

pub const NV_ENC_PIC_TYPE_P: c_int = 0;
pub const NV_ENC_PIC_TYPE_B: c_int = 1;
pub const NV_ENC_PIC_TYPE_I: c_int = 2;
pub const NV_ENC_PIC_TYPE_IDR: c_int = 3;
pub const NV_ENC_PIC_TYPE_BI: c_int = 4;
pub const NV_ENC_PIC_TYPE_SKIPPED: c_int = 5;
pub const NV_ENC_PIC_TYPE_INTRA_REFRESH: c_int = 6;
pub const NV_ENC_PIC_TYPE_NONREF_P: c_int = 7;
pub const NV_ENC_PIC_TYPE_UNKNOWN: c_int = 255;
pub const enum__NV_ENC_PIC_TYPE = c_uint;
pub const NV_ENC_PIC_TYPE = enum__NV_ENC_PIC_TYPE;

pub const struct__NV_ENC_SEI_PAYLOAD = extern struct {
    payloadSize: u32 = @import("std").mem.zeroes(u32),
    payloadType: u32 = @import("std").mem.zeroes(u32),
    payload: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
pub const NV_ENC_H264_SEI_PAYLOAD = NV_ENC_SEI_PAYLOAD;

pub const struct__NV_ENC_PIC_PARAMS_H264 = extern struct {
    displayPOCSyntax: u32 = @import("std").mem.zeroes(u32),
    reserved3: u32 = @import("std").mem.zeroes(u32),
    refPicFlag: u32 = @import("std").mem.zeroes(u32),
    colourPlaneId: u32 = @import("std").mem.zeroes(u32),
    forceIntraRefreshWithFrameCnt: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    sliceTypeData: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    sliceTypeArrayCnt: u32 = @import("std").mem.zeroes(u32),
    seiPayloadArrayCnt: u32 = @import("std").mem.zeroes(u32),
    seiPayloadArray: [*c]NV_ENC_SEI_PAYLOAD = @import("std").mem.zeroes([*c]NV_ENC_SEI_PAYLOAD),
    sliceMode: u32 = @import("std").mem.zeroes(u32),
    sliceModeData: u32 = @import("std").mem.zeroes(u32),
    ltrMarkFrameIdx: u32 = @import("std").mem.zeroes(u32),
    ltrUseFrameBitmap: u32 = @import("std").mem.zeroes(u32),
    ltrUsageMode: u32 = @import("std").mem.zeroes(u32),
    forceIntraSliceCount: u32 = @import("std").mem.zeroes(u32),
    forceIntraSliceIdx: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    reserved: [242]u32 = @import("std").mem.zeroes([242]u32),
    reserved2: [61]?*anyopaque = @import("std").mem.zeroes([61]?*anyopaque),
};

pub const struct__NV_ENC_PIC_PARAMS_HEVC = extern struct {
    displayPOCSyntax: u32 = @import("std").mem.zeroes(u32),
    refPicFlag: u32 = @import("std").mem.zeroes(u32),
    temporalId: u32 = @import("std").mem.zeroes(u32),
    forceIntraRefreshWithFrameCnt: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    sliceTypeData: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    sliceTypeArrayCnt: u32 = @import("std").mem.zeroes(u32),
    sliceMode: u32 = @import("std").mem.zeroes(u32),
    sliceModeData: u32 = @import("std").mem.zeroes(u32),
    ltrMarkFrameIdx: u32 = @import("std").mem.zeroes(u32),
    ltrUseFrameBitmap: u32 = @import("std").mem.zeroes(u32),
    ltrUsageMode: u32 = @import("std").mem.zeroes(u32),
    seiPayloadArrayCnt: u32 = @import("std").mem.zeroes(u32),
    reserved: u32 = @import("std").mem.zeroes(u32),
    seiPayloadArray: [*c]NV_ENC_SEI_PAYLOAD = @import("std").mem.zeroes([*c]NV_ENC_SEI_PAYLOAD),
    reserved2: [244]u32 = @import("std").mem.zeroes([244]u32),
    reserved3: [61]?*anyopaque = @import("std").mem.zeroes([61]?*anyopaque),
};

pub const struct__NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE = extern struct {
    reserved: u32 = @import("std").mem.zeroes(u32),
    reserved1: [3]u32 = @import("std").mem.zeroes([3]u32),
};

pub const struct__NVENC_EXTERNAL_ME_HINT = extern struct {
    reserved: i32 = @import("std").mem.zeroes(i32),
};

pub const union__NV_ENC_CODEC_PIC_PARAMS = extern union {
    h264PicParams: NV_ENC_PIC_PARAMS_H264,
    hevcPicParams: NV_ENC_PIC_PARAMS_HEVC,
    reserved: [256]u32,
};

pub const struct__NV_ENC_PIC_PARAMS = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    inputWidth: u32 = @import("std").mem.zeroes(u32),
    inputHeight: u32 = @import("std").mem.zeroes(u32),
    inputPitch: u32 = @import("std").mem.zeroes(u32),
    encodePicFlags: u32 = @import("std").mem.zeroes(u32),
    frameIdx: u32 = @import("std").mem.zeroes(u32),
    inputTimeStamp: u64 = @import("std").mem.zeroes(u64),
    inputDuration: u64 = @import("std").mem.zeroes(u64),
    inputBuffer: NV_ENC_INPUT_PTR = @import("std").mem.zeroes(NV_ENC_INPUT_PTR),
    outputBitstream: NV_ENC_OUTPUT_PTR = @import("std").mem.zeroes(NV_ENC_OUTPUT_PTR),
    completionEvent: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    bufferFmt: NV_ENC_BUFFER_FORMAT = @import("std").mem.zeroes(NV_ENC_BUFFER_FORMAT),
    pictureStruct: NV_ENC_PIC_STRUCT = @import("std").mem.zeroes(NV_ENC_PIC_STRUCT),
    pictureType: NV_ENC_PIC_TYPE = @import("std").mem.zeroes(NV_ENC_PIC_TYPE),
    codecPicParams: NV_ENC_CODEC_PIC_PARAMS = @import("std").mem.zeroes(NV_ENC_CODEC_PIC_PARAMS),
    meHintCountsPerBlock: [2]NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE = @import("std").mem.zeroes([2]NVENC_EXTERNAL_ME_HINT_COUNTS_PER_BLOCKTYPE),
    meExternalHints: ?*NVENC_EXTERNAL_ME_HINT = @import("std").mem.zeroes(?*NVENC_EXTERNAL_ME_HINT),
    reserved1: [6]u32 = @import("std").mem.zeroes([6]u32),
    reserved2: [2]?*anyopaque = @import("std").mem.zeroes([2]?*anyopaque),
    qpDeltaMap: [*c]i8 = @import("std").mem.zeroes([*c]i8),
    qpDeltaMapSize: u32 = @import("std").mem.zeroes(u32),
    reservedBitFields: u32 = @import("std").mem.zeroes(u32),
    meHintRefPicDist: [2]u16 = @import("std").mem.zeroes([2]u16),
    reserved3: [286]u32 = @import("std").mem.zeroes([286]u32),
    reserved4: [60]?*anyopaque = @import("std").mem.zeroes([60]?*anyopaque),
};

pub const struct__NV_ENC_LOCK_BITSTREAM = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    outputBitstream: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    sliceOffsets: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    frameIdx: u32 = @import("std").mem.zeroes(u32),
    hwEncodeStatus: u32 = @import("std").mem.zeroes(u32),
    numSlices: u32 = @import("std").mem.zeroes(u32),
    bitstreamSizeInBytes: u32 = @import("std").mem.zeroes(u32),
    outputTimeStamp: u64 = @import("std").mem.zeroes(u64),
    outputDuration: u64 = @import("std").mem.zeroes(u64),
    bitstreamBufferPtr: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    pictureType: NV_ENC_PIC_TYPE = @import("std").mem.zeroes(NV_ENC_PIC_TYPE),
    pictureStruct: NV_ENC_PIC_STRUCT = @import("std").mem.zeroes(NV_ENC_PIC_STRUCT),
    frameAvgQP: u32 = @import("std").mem.zeroes(u32),
    frameSatd: u32 = @import("std").mem.zeroes(u32),
    ltrFrameIdx: u32 = @import("std").mem.zeroes(u32),
    ltrFrameBitmap: u32 = @import("std").mem.zeroes(u32),
    reserved: [13]u32 = @import("std").mem.zeroes([13]u32),
    intraMBCount: u32 = @import("std").mem.zeroes(u32),
    interMBCount: u32 = @import("std").mem.zeroes(u32),
    averageMVX: i32 = @import("std").mem.zeroes(i32),
    averageMVY: i32 = @import("std").mem.zeroes(i32),
    reserved1: [219]u32 = @import("std").mem.zeroes([219]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const struct__NV_ENC_LOCK_INPUT_BUFFER = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    bitFlags1: u32 = @import("std").mem.zeroes(u32),
    inputBuffer: NV_ENC_INPUT_PTR = @import("std").mem.zeroes(NV_ENC_INPUT_PTR),
    bufferDataPtr: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    pitch: u32 = @import("std").mem.zeroes(u32),
    reserved1: [251]u32 = @import("std").mem.zeroes([251]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const struct__NV_ENC_SEQUENCE_PARAM_PAYLOAD = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    inBufferSize: u32 = @import("std").mem.zeroes(u32),
    spsId: u32 = @import("std").mem.zeroes(u32),
    ppsId: u32 = @import("std").mem.zeroes(u32),
    spsppsBuffer: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    outSPSPPSPayloadSize: [*c]u32 = @import("std").mem.zeroes([*c]u32),
    reserved: [250]u32 = @import("std").mem.zeroes([250]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const NV_ENC_DEVICE_TYPE_DIRECTX: c_int = 0;
pub const NV_ENC_DEVICE_TYPE_CUDA: c_int = 1;
pub const NV_ENC_DEVICE_TYPE_OPENGL: c_int = 2;
pub const enum__NV_ENC_DEVICE_TYPE = c_uint;
pub const NV_ENC_DEVICE_TYPE = enum__NV_ENC_DEVICE_TYPE;

pub const struct__NV_ENC_OPEN_ENCODE_SESSIONEX_PARAMS = extern struct {
    version: u32 = @import("std").mem.zeroes(u32),
    deviceType: NV_ENC_DEVICE_TYPE = @import("std").mem.zeroes(NV_ENC_DEVICE_TYPE),
    device: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    reserved: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    apiVersion: u32 = @import("std").mem.zeroes(u32),
    reserved1: [253]u32 = @import("std").mem.zeroes([253]u32),
    reserved2: [64]?*anyopaque = @import("std").mem.zeroes([64]?*anyopaque),
};

pub const PNVENCOPENENCODESESSION = ?*const fn (?*anyopaque, u32, [*c]?*anyopaque) callconv(.C) NVENCSTATUS;
pub const PNVENCINITIALIZEENCODER = ?*const fn (?*anyopaque, ?*NV_ENC_INITIALIZE_PARAMS) callconv(.C) NVENCSTATUS;
pub const PNVENCCREATEINPUTBUFFER = ?*const fn (?*anyopaque, [*c]NV_ENC_CREATE_INPUT_BUFFER) callconv(.C) NVENCSTATUS;
pub const PNVENCDESTROYINPUTBUFFER = ?*const fn (?*anyopaque, NV_ENC_INPUT_PTR) callconv(.C) NVENCSTATUS;
pub const PNVENCCREATEBITSTREAMBUFFER = ?*const fn (?*anyopaque, [*c]NV_ENC_CREATE_BITSTREAM_BUFFER) callconv(.C) NVENCSTATUS;
pub const PNVENCDESTROYBITSTREAMBUFFER = ?*const fn (?*anyopaque, NV_ENC_OUTPUT_PTR) callconv(.C) NVENCSTATUS;
pub const PNVENCENCODEPICTURE = ?*const fn (?*anyopaque, ?*NV_ENC_PIC_PARAMS) callconv(.C) NVENCSTATUS;
pub const PNVENCLOCKBITSTREAM = ?*const fn (?*anyopaque, ?*NV_ENC_LOCK_BITSTREAM) callconv(.C) NVENCSTATUS;
pub const PNVENCUNLOCKBITSTREAM = ?*const fn (?*anyopaque, NV_ENC_OUTPUT_PTR) callconv(.C) NVENCSTATUS;
pub const PNVENCLOCKINPUTBUFFER = ?*const fn (?*anyopaque, ?*NV_ENC_LOCK_INPUT_BUFFER) callconv(.C) NVENCSTATUS;
pub const PNVENCUNLOCKINPUTBUFFER = ?*const fn (?*anyopaque, NV_ENC_INPUT_PTR) callconv(.C) NVENCSTATUS;
pub const PNVENCGETSEQUENCEPARAMS = ?*const fn (?*anyopaque, [*c]NV_ENC_SEQUENCE_PARAM_PAYLOAD) callconv(.C) NVENCSTATUS;
pub const PNVENCDESTROYENCODER = ?*const fn (?*anyopaque) callconv(.C) NVENCSTATUS;
pub const PNVENCOPENENCODESESSIONEX = ?*const fn ([*c]NV_ENC_OPEN_ENCODE_SESSION_EX_PARAMS, [*c]?*anyopaque) callconv(.C) NVENCSTATUS;
pub const PNVENCGETLASTERROR = ?*const fn (?*anyopaque) callconv(.C) [*c]const u8;

pub const NV_ENCODE_API_FUNCTION_LIST = extern struct {
    version: u32,
    reserved: u32,
    nvEncOpenEncodeSession: PNVENCOPENENCODESESSION,
    nvEncGetEncodeGUIDCount: ?*anyopaque, // not included in bindings
    nvEncGetEncodeProfileGUIDCount: ?*anyopaque, // not included in bindings,
    nvEncGetEncodeProfileGUIDs: ?*anyopaque, // not included in bindings
    nvEncGetEncodeGUIDs: ?*anyopaque, // not included in bindings
    nvEncGetInputFormatCount: ?*anyopaque, // not included in bindings
    nvEncGetInputFormats: ?*anyopaque, // not included in bindings
    nvEncGetEncodeCaps: ?*anyopaque, // not included in bindings
    nvEncGetEncodePresetCount: ?*anyopaque, // not included in bindings
    nvEncGetEncodePresetGUIDs: ?*anyopaque, // not included in bindings
    nvEncGetEncodePresetConfig: ?*anyopaque, // not included in bindings
    nvEncInitializeEncoder: PNVENCINITIALIZEENCODER,
    nvEncCreateInputBuffer: PNVENCCREATEINPUTBUFFER,
    nvEncDestroyInputBuffer: PNVENCDESTROYINPUTBUFFER,
    nvEncCreateBitstreamBuffer: PNVENCCREATEBITSTREAMBUFFER,
    nvEncDestroyBitstreamBuffer: PNVENCDESTROYBITSTREAMBUFFER,
    nvEncEncodePicture: PNVENCENCODEPICTURE,
    nvEncLockBitstream: PNVENCLOCKBITSTREAM,
    nvEncUnlockBitstream: PNVENCUNLOCKBITSTREAM,
    nvEncLockInputBuffer: PNVENCLOCKINPUTBUFFER,
    nvEncUnlockInputBuffer: PNVENCUNLOCKINPUTBUFFER,
    nvEncGetEncodeStats: ?*anyopaque, // not included in bindings
    nvEncGetSequenceParams: PNVENCGETSEQUENCEPARAMS,
    nvEncRegisterAsyncEvent: ?*anyopaque, // not included in bindings
    nvEncUnregisterAsyncEvent: ?*anyopaque, // not included in bindings
    nvEncMapInputResource: ?*anyopaque, // not included in bindings
    nvEncUnmapInputResource: ?*anyopaque, // not included in bindings
    nvEncDestroyEncoder: PNVENCDESTROYENCODER,
    nvEncInvalidateRefFrames: ?*anyopaque, // not included in bindings
    nvEncOpenEncodeSessionEx: PNVENCOPENENCODESESSIONEX,
    nvEncRegisterResource: ?*anyopaque, // not included in bindings
    nvEncUnregisterResource: ?*anyopaque, // not included in bindings
    nvEncReconfigureEncoder: ?*anyopaque, // not included in bindings
    _reserved1: ?*anyopaque,
    nvEncCreateMVBuffer: ?*anyopaque, // not included in bindings
    nvEncDestroyMVBuffer: ?*anyopaque, // not included in bindings
    nvEncRunMotionEstimationOnly: ?*anyopaque, // not included in bindings
    nvEncGetLastErrorString: PNVENCGETLASTERROR,
    nvEncSetIOCudaStreams: ?*anyopaque, // not included in bindings
    _reserved2: [279]?*anyopaque,
};

pub extern fn NvEncodeAPICreateInstance(functionList: [*c]NV_ENCODE_API_FUNCTION_LIST) NVENCSTATUS;

pub const NV_ENC_CODEC_H264_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1808279394))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 20067))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19620))))),
    .Data4 = [8]u8{ 170, 133, 30, 80, 243, 33, 246, 191 },
};
pub const NV_ENC_CODEC_HEVC_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 2030886024))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17698))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19835))))),
    .Data4 = [8]u8{ 148, 37, 189, 169, 151, 95, 118, 3 },
};
pub const NV_ENC_CODEC_PROFILE_AUTOSELECT_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3218536679),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 9020))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17217))))),
    .Data4 = [8]u8{ 139, 62, 72, 24, 82, 56, 3, 244 },
};
pub const NV_ENC_H264_PROFILE_BASELINE_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 120044714))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 30916))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19587))))),
    .Data4 = [8]u8{ 140, 47, 239, 61, 255, 38, 124, 106 },
};
pub const NV_ENC_H264_PROFILE_MAIN_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1622524372))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 26622))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 18320))))),
    .Data4 = [8]u8{ 148, 213, 196, 114, 109, 123, 110, 109 },
};
pub const NV_ENC_H264_PROFILE_HIGH_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3888890633),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 20346))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19337))))),
    .Data4 = [8]u8{ 175, 42, 213, 55, 201, 43, 227, 16 },
};
pub const NV_ENC_H264_PROFILE_HIGH_444_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 2059822027))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 42392))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 18784))))),
    .Data4 = [8]u8{ 184, 68, 51, 155, 38, 26, 125, 82 },
};
pub const NV_ENC_H264_PROFILE_STEREO_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1082424309))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 13303))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17921))))),
    .Data4 = [8]u8{ 144, 132, 232, 254, 60, 29, 184, 183 },
};
pub const NV_ENC_H264_PROFILE_SVC_TEMPORAL_SCALABILTY: GUID = GUID{
    .Data1 = @as(c_uint, 3464006944),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 43689))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17176))))),
    .Data4 = [8]u8{ 146, 187, 172, 126, 133, 140, 141, 54 },
};
pub const NV_ENC_H264_PROFILE_PROGRESSIVE_HIGH_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3020271532),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 62251))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 16763))))),
    .Data4 = [8]u8{ 137, 196, 154, 190, 237, 62, 89, 120 },
};
pub const NV_ENC_H264_PROFILE_CONSTRAINED_HIGH_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 2931932551),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 59483))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 18674))))),
    .Data4 = [8]u8{ 132, 195, 152, 188, 166, 40, 80, 114 },
};
pub const NV_ENC_HEVC_PROFILE_MAIN_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3038036890),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 46427))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 16634))))),
    .Data4 = [8]u8{ 135, 143, 241, 37, 59, 77, 253, 236 },
};
pub const NV_ENC_HEVC_PROFILE_MAIN10_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 4199361388),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 14939))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 16666))))),
    .Data4 = [8]u8{ 128, 24, 10, 63, 94, 60, 155, 229 },
};
pub const NV_ENC_HEVC_PROFILE_FREXT_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1374433973))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 6988))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17724))))),
    .Data4 = [8]u8{ 156, 189, 182, 22, 189, 98, 19, 65 },
};
pub const NV_ENC_PRESET_DEFAULT_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3001005829),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 20157))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19529))))),
    .Data4 = [8]u8{ 155, 95, 36, 167, 119, 211, 229, 135 },
};
pub const NV_ENC_PRESET_HP_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1625605535))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 59462))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17540))))),
    .Data4 = [8]u8{ 165, 109, 205, 69, 190, 159, 221, 246 },
};
pub const NV_ENC_PRESET_HQ_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 886810397))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 42875))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19343))))),
    .Data4 = [8]u8{ 156, 62, 182, 213, 218, 36, 192, 18 },
};
pub const NV_ENC_PRESET_BD_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 2195973200),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 48571))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 20032))))),
    .Data4 = [8]u8{ 152, 156, 130, 169, 13, 249, 239, 50 },
};
pub const NV_ENC_PRESET_LOW_LATENCY_DEFAULT_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1239359941))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 28154))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 20459))))),
    .Data4 = [8]u8{ 151, 135, 106, 204, 158, 255, 183, 38 },
};
pub const NV_ENC_PRESET_LOW_LATENCY_HQ_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3321312185),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 60055))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19705))))),
    .Data4 = [8]u8{ 190, 194, 191, 120, 167, 79, 209, 5 },
};
pub const NV_ENC_PRESET_LOW_LATENCY_HP_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 1728588356))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 19373))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 18682))))),
    .Data4 = [8]u8{ 152, 234, 147, 5, 109, 21, 10, 88 },
};
pub const NV_ENC_PRESET_LOSSLESS_DEFAULT_GUID: GUID = GUID{
    .Data1 = @as(c_uint, 3586111254),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 50692))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 17639))))),
    .Data4 = [8]u8{ 155, 184, 222, 165, 81, 15, 195, 172 },
};
pub const NV_ENC_PRESET_LOSSLESS_HP_GUID: GUID = GUID{
    .Data1 = @as(u32, @bitCast(@as(c_int, 345610471))),
    .Data2 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 9060))))),
    .Data3 = @as(u16, @bitCast(@as(c_short, @truncate(@as(c_int, 16669))))),
    .Data4 = [8]u8{ 130, 239, 23, 152, 136, 9, 52, 9 },
};

pub const NV_ENC_LEVEL_AUTOSELECT: c_int = 0;
pub const NV_ENC_LEVEL_H264_1: c_int = 10;
pub const NV_ENC_LEVEL_H264_1b: c_int = 9;
pub const NV_ENC_LEVEL_H264_11: c_int = 11;
pub const NV_ENC_LEVEL_H264_12: c_int = 12;
pub const NV_ENC_LEVEL_H264_13: c_int = 13;
pub const NV_ENC_LEVEL_H264_2: c_int = 20;
pub const NV_ENC_LEVEL_H264_21: c_int = 21;
pub const NV_ENC_LEVEL_H264_22: c_int = 22;
pub const NV_ENC_LEVEL_H264_3: c_int = 30;
pub const NV_ENC_LEVEL_H264_31: c_int = 31;
pub const NV_ENC_LEVEL_H264_32: c_int = 32;
pub const NV_ENC_LEVEL_H264_4: c_int = 40;
pub const NV_ENC_LEVEL_H264_41: c_int = 41;
pub const NV_ENC_LEVEL_H264_42: c_int = 42;
pub const NV_ENC_LEVEL_H264_5: c_int = 50;
pub const NV_ENC_LEVEL_H264_51: c_int = 51;
pub const NV_ENC_LEVEL_H264_52: c_int = 52;
pub const NV_ENC_LEVEL_HEVC_1: c_int = 30;
pub const NV_ENC_LEVEL_HEVC_2: c_int = 60;
pub const NV_ENC_LEVEL_HEVC_21: c_int = 63;
pub const NV_ENC_LEVEL_HEVC_3: c_int = 90;
pub const NV_ENC_LEVEL_HEVC_31: c_int = 93;
pub const NV_ENC_LEVEL_HEVC_4: c_int = 120;
pub const NV_ENC_LEVEL_HEVC_41: c_int = 123;
pub const NV_ENC_LEVEL_HEVC_5: c_int = 150;
pub const NV_ENC_LEVEL_HEVC_51: c_int = 153;
pub const NV_ENC_LEVEL_HEVC_52: c_int = 156;
pub const NV_ENC_LEVEL_HEVC_6: c_int = 180;
pub const NV_ENC_LEVEL_HEVC_61: c_int = 183;
pub const NV_ENC_LEVEL_HEVC_62: c_int = 186;
pub const NV_ENC_TIER_HEVC_MAIN: c_int = 0;
pub const NV_ENC_TIER_HEVC_HIGH: c_int = 1;
pub const enum__NV_ENC_LEVEL = c_uint;
pub const NV_ENC_LEVEL = enum__NV_ENC_LEVEL;

pub const NV_ENC_PIC_FLAG_FORCEINTRA: c_int = 1;
pub const NV_ENC_PIC_FLAG_FORCEIDR: c_int = 2;
pub const NV_ENC_PIC_FLAG_OUTPUT_SPSPPS: c_int = 4;
pub const NV_ENC_PIC_FLAG_EOS: c_int = 8;
pub const enum__NV_ENC_PIC_FLAGS = c_uint;
pub const NV_ENC_PIC_FLAGS = enum__NV_ENC_PIC_FLAGS;

pub const NV_ENC_NUM_REF_FRAMES_AUTOSELECT: c_int = 0;
pub const NV_ENC_NUM_REF_FRAMES_1: c_int = 1;
pub const NV_ENC_NUM_REF_FRAMES_2: c_int = 2;
pub const NV_ENC_NUM_REF_FRAMES_3: c_int = 3;
pub const NV_ENC_NUM_REF_FRAMES_4: c_int = 4;
pub const NV_ENC_NUM_REF_FRAMES_5: c_int = 5;
pub const NV_ENC_NUM_REF_FRAMES_6: c_int = 6;
pub const NV_ENC_NUM_REF_FRAMES_7: c_int = 7;
pub const enum__NV_ENC_NUM_REF_FRAMES = c_uint;
pub const NV_ENC_NUM_REF_FRAMES = enum__NV_ENC_NUM_REF_FRAMES;

pub const NVENC_INFINITE_GOPLENGTH = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffffffff, .hex);

pub const NV_MAX_SEQ_HDR_LEN = @as(c_int, 512);

pub inline fn NVENCAPI_STRUCT_VERSION(ver: anytype) @TypeOf((@import("std").zig.c_translation.cast(u32, NVENCAPI_VERSION) | (ver << @as(c_int, 16))) | (@as(c_int, 0x7) << @as(c_int, 28))) {
    _ = &ver;
    return (@import("std").zig.c_translation.cast(u32, NVENCAPI_VERSION) | (ver << @as(c_int, 16))) | (@as(c_int, 0x7) << @as(c_int, 28));
}
pub const NV_ENC_CAPS_PARAM_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_ENCODE_OUT_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_CREATE_INPUT_BUFFER_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_CREATE_BITSTREAM_BUFFER_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_CREATE_MV_BUFFER_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_RC_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_CONFIG_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 7)) | (@as(c_int, 1) << @as(c_int, 31));
pub const NV_ENC_INITIALIZE_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 5)) | (@as(c_int, 1) << @as(c_int, 31));
pub const NV_ENC_RECONFIGURE_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1)) | (@as(c_int, 1) << @as(c_int, 31));
pub const NV_ENC_PRESET_CONFIG_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 4)) | (@as(c_int, 1) << @as(c_int, 31));
pub const NV_ENC_PIC_PARAMS_MVC_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_PIC_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 4)) | (@as(c_int, 1) << @as(c_int, 31));
pub const NV_ENC_MEONLY_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 3));
pub const NV_ENC_LOCK_BITSTREAM_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_LOCK_INPUT_BUFFER_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_MAP_INPUT_RESOURCE_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 4));
pub const NV_ENC_REGISTER_RESOURCE_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 3));
pub const NV_ENC_STAT_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_SEQUENCE_PARAM_PAYLOAD_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_EVENT_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENC_OPEN_ENCODE_SESSION_EX_PARAMS_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 1));
pub const NV_ENCODE_API_FUNCTION_LIST_VER = NVENCAPI_STRUCT_VERSION(@as(c_int, 2));
