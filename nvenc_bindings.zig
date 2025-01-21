pub const api_major_version: u32 = 10;
pub const api_minor_version: u32 = 0;
pub const api_version: u32 = api_major_version | (api_minor_version << 24);

pub inline fn struct_version(v: u32) u32 {
    return api_version | (v << 16) | (0x7 << 28);
}

pub const caps_param_ver = struct_version(1);
pub const encode_out_params_ver = struct_version(1);
pub const create_input_buffer_ver = struct_version(1);
pub const create_bitstream_buffer_ver = struct_version(1);
pub const create_mv_buffer_ver = struct_version(1);
pub const rc_params_ver = struct_version(1);
pub const config_ver = struct_version(7) | (1 << 31);
pub const initialize_params_ver = struct_version(5) | (1 << 31);
pub const reconfigure_params_ver = struct_version(1) | (1 << 31);
pub const preset_config_ver = struct_version(4) | (1 << 31);
pub const pic_params_ver = struct_version(4) | (1 << 31);
pub const pic_params_mvc_ver = struct_version(1);
pub const meonly_params_ver = struct_version(3);
pub const lock_bitstream_ver = struct_version(1);
pub const lock_input_buffer_ver = struct_version(1);
pub const map_input_resource_ver = struct_version(4);
pub const register_resource_ver = struct_version(3);
pub const stat_ver = struct_version(1);
pub const sequence_param_payload_ver = struct_version(1);
pub const event_params_ver = struct_version(1);
pub const open_encode_session_ex_params_ver = struct_version(1);
pub const api_function_list_ver = struct_version(2);

pub inline fn guid(part1: u32, part2: u16, part3: u16, part4: [8]u8) GUID {
    return GUID{ .Data1 = part1, .Data2 = part2, .Data3 = part3, .Data4 = part4 };
}

pub const codec_h264_guid = guid(0x6bc82762, 0x4e63, 0x4ca4, .{ 0xaa, 0x85, 0x1e, 0x50, 0xf3, 0x21, 0xf6, 0xbf });
pub const codec_hevc_guid = guid(0x790cdc88, 0x4522, 0x4d7b, .{ 0x94, 0x25, 0xbd, 0xa9, 0x97, 0x5f, 0x76, 0x3 });
pub const codec_profile_autoselect_guid = guid(0xbfd6f8e7, 0x233c, 0x4341, .{ 0x8b, 0x3e, 0x48, 0x18, 0x52, 0x38, 0x3, 0xf4 });
pub const h264_profile_baseline_guid = guid(0x727bcaa, 0x78c4, 0x4c83, .{ 0x8c, 0x2f, 0xef, 0x3d, 0xff, 0x26, 0x7c, 0x6a });
pub const h264_profile_main_guid = guid(0x60b5c1d4, 0x67fe, 0x4790, .{ 0x94, 0xd5, 0xc4, 0x72, 0x6d, 0x7b, 0x6e, 0x6d });
pub const h264_profile_high_guid = guid(0xe7cbc309, 0x4f7a, 0x4b89, .{ 0xaf, 0x2a, 0xd5, 0x37, 0xc9, 0x2b, 0xe3, 0x10 });
pub const h264_profile_high_444_guid = guid(0x7ac663cb, 0xa598, 0x4960, .{ 0xb8, 0x44, 0x33, 0x9b, 0x26, 0x1a, 0x7d, 0x52 });
pub const h264_profile_stereo_guid = guid(0x40847bf5, 0x33f7, 0x4601, .{ 0x90, 0x84, 0xe8, 0xfe, 0x3c, 0x1d, 0xb8, 0xb7 });
pub const h264_profile_svc_temporal_scalabilty = guid(0xce788d20, 0xaaa9, 0x4318, .{ 0x92, 0xbb, 0xac, 0x7e, 0x85, 0x8c, 0x8d, 0x36 });
pub const h264_profile_progressive_high_guid = guid(0xb405afac, 0xf32b, 0x417b, .{ 0x89, 0xc4, 0x9a, 0xbe, 0xed, 0x3e, 0x59, 0x78 });
pub const h264_profile_constrained_high_guid = guid(0xaec1bd87, 0xe85b, 0x48f2, .{ 0x84, 0xc3, 0x98, 0xbc, 0xa6, 0x28, 0x50, 0x72 });
pub const hevc_profile_main_guid = guid(0xb514c39a, 0xb55b, 0x40fa, .{ 0x87, 0x8f, 0xf1, 0x25, 0x3b, 0x4d, 0xfd, 0xec });
pub const hevc_profile_main10_guid = guid(0xfa4d2b6c, 0x3a5b, 0x411a, .{ 0x80, 0x18, 0x0a, 0x3f, 0x5e, 0x3c, 0x9b, 0xe5 });
pub const hevc_profile_frext_guid = guid(0x51ec32b5, 0x1b4c, 0x453c, .{ 0x9c, 0xbd, 0xb6, 0x16, 0xbd, 0x62, 0x13, 0x41 });

// The old presets were deprecated starting SDK version 10.0. We remove them
// entirely since using them is not supported on modern driver versions.
// pub const preset_default_guid = guid(0xb2dfb705, 0x4ebd, 0x4c49, .{ 0x9b, 0x5f, 0x24, 0xa7, 0x77, 0xd3, 0xe5, 0x87 });
// pub const preset_hp_guid = guid(0x60e4c59f, 0xe846, 0x4484, .{ 0xa5, 0x6d, 0xcd, 0x45, 0xbe, 0x9f, 0xdd, 0xf6 });
// pub const preset_hq_guid = guid(0x34dba71d, 0xa77b, 0x4b8f, .{ 0x9c, 0x3e, 0xb6, 0xd5, 0xda, 0x24, 0xc0, 0x12 });
// pub const preset_bd_guid = guid(0x82e3e450, 0xbdbb, 0x4e40, .{ 0x98, 0x9c, 0x82, 0xa9, 0xd, 0xf9, 0xef, 0x32 });
// pub const preset_low_latency_default_guid = guid(0x49df21c5, 0x6dfa, 0x4feb, .{ 0x97, 0x87, 0x6a, 0xcc, 0x9e, 0xff, 0xb7, 0x26 });
// pub const preset_low_latency_hq_guid = guid(0xc5f733b9, 0xea97, 0x4cf9, .{ 0xbe, 0xc2, 0xbf, 0x78, 0xa7, 0x4f, 0xd1, 0x5 });
// pub const preset_low_latency_hp_guid = guid(0x67082a44, 0x4bad, 0x48fa, .{ 0x98, 0xea, 0x93, 0x5, 0x6d, 0x15, 0xa, 0x58 });
// pub const preset_lossless_default_guid = guid(0xd5bfb716, 0xc604, 0x44e7, .{ 0x9b, 0xb8, 0xde, 0xa5, 0x51, 0xf, 0xc3, 0xac });
// pub const preset_lossless_hp_guid = guid(0x149998e7, 0x2364, 0x411d, .{ 0x82, 0xef, 0x17, 0x98, 0x88, 0x9, 0x34, 0x9 });

pub const preset_p1 = guid(0xfc0a8d3e, 0x45f8, 0x4cf8, .{ 0x80, 0xc7, 0x29, 0x88, 0x71, 0x59, 0x0e, 0xbf });
pub const preset_p2 = guid(0xf581cfb8, 0x88d6, 0x4381, .{ 0x93, 0xf0, 0xdf, 0x13, 0xf9, 0xc2, 0x7d, 0xab });
pub const preset_p3 = guid(0x36850110, 0x3a07, 0x441f, .{ 0x94, 0xd5, 0x36, 0x70, 0x63, 0x1f, 0x91, 0xf6 });
pub const preset_p4 = guid(0x90a7b826, 0xdf06, 0x4862, .{ 0xb9, 0xd2, 0xcd, 0x6d, 0x73, 0xa0, 0x86, 0x81 });
pub const preset_p5 = guid(0x21c6e6b4, 0x297a, 0x4cba, .{ 0x99, 0x8f, 0xb6, 0xcb, 0xde, 0x72, 0xad, 0xe3 });
pub const preset_p6 = guid(0x8e75c279, 0x6299, 0x4ab6, .{ 0x83, 0x02, 0x0b, 0x21, 0x5a, 0x33, 0x5c, 0xf5 });
pub const preset_p7 = guid(0x84848c12, 0x6f71, 0x4c13, .{ 0x93, 0x1b, 0x53, 0xe2, 0x83, 0xf5, 0x79, 0x74 });

pub const infinite_goplength: u32 = 0xffffffff;

pub const BFrameRefMode = enum(c_uint) {
    disabled = 0,
    each = 1,
    middle = 2,
};

pub const BufferFormat = enum(c_uint) {
    undefined = 0,
    nv12 = 1,
    yv12 = 16,
    iyuv = 256,
    yuv444 = 4096,
    yuv420_10bit = 65536,
    yuv444_10bit = 1048576,
    argb = 16777216,
    argb10 = 33554432,
    ayuv = 67108864,
    abgr = 268435456,
    abgr10 = 536870912,
    u8 = 1073741824,
};

pub const BufferUsage = enum(c_uint) {
    input_image = 0,
    output_motion_vector = 1,
    output_bitstream = 2,
};

pub const DeviceType = enum(c_uint) {
    directx = 0,
    cuda = 1,
    opengl = 2,
};

pub const H264AdaptiveTransformMode = enum(c_uint) {
    autoselect = 0,
    disable = 1,
    enable = 2,
};

pub const H264BDirectMode = enum(c_uint) {
    autoselect = 0,
    disable = 1,
    temporal = 2,
    spatial = 3,
};

pub const H264EntropyCodingMode = enum(c_uint) {
    autoselect = 0,
    cabac = 1,
    cavlc = 2,
};

pub const H264FMOMode = enum(c_uint) {
    autoselect = 0,
    enable = 1,
    disable = 2,
};

pub const HEVCCusize = enum(c_uint) {
    autoselect = 0,
    @"8x8" = 1,
    @"16x16" = 2,
    @"32x32" = 3,
    @"64x64" = 4,
};

pub const InputResourceType = enum(c_uint) {
    directx = 0,
    cudadeviceptr = 1,
    cudaarray = 2,
    opengl_tex = 3,
};

pub const Level = enum(c_uint) {
    autoselect = 0,

    h264_1 = 10,
    h264_1b = 9,
    h264_11 = 11,
    h264_12 = 12,
    h264_13 = 13,
    h264_2 = 20,
    h264_21 = 21,
    h264_22 = 22,
    h264_3 = 30,
    h264_31 = 31,
    h264_32 = 32,
    h264_4 = 40,
    h264_41 = 41,
    h264_42 = 42,
    h264_5 = 50,
    h264_51 = 51,
    h264_52 = 52,
    h264_60 = 60,
    h264_61 = 61,
    h264_62 = 62,

    hevc_1 = 30,
    hevc_2 = 60,
    hevc_21 = 63,
    hevc_3 = 90,
    hevc_31 = 93,
    hevc_4 = 120,
    hevc_41 = 123,
    hevc_5 = 150,
    hevc_51 = 153,
    hevc_52 = 156,
    hevc_6 = 180,
    hevc_61 = 183,
    hevc_62 = 186,
    hevc_main = 0,
    hevc_high = 1,
};

pub const MemoryHeap = enum(c_uint) {
    autoselect = 0,
    vid = 1,
    sysmem_cached = 2,
    sysmem_uncached = 3,
};

pub const MVPrecision = enum(c_uint) {
    default = 0,
    full_pel = 1,
    half_pel = 2,
    quarter_pel = 3,
};

pub const MultiPass = enum(c_uint) {
    disabled = 0,
    two_pass_quarter_resolution = 1,
    two_pass_full_resolution = 2,
};

pub const NumRefFrames = enum(c_uint) {
    autoselect = 0,
    @"1" = 1,
    @"2" = 2,
    @"3" = 3,
    @"4" = 4,
    @"5" = 5,
    @"6" = 6,
    @"7" = 7,
};

pub const ParamsFrameFieldMode = enum(c_uint) {
    frame = 1,
    field = 2,
    mbaff = 3,
};

pub const ParamsRcMode = enum(c_uint) {
    constqp = 0,
    vbr = 1,
    cbr = 2,
};

pub const PicFlags = enum(c_uint) {
    forceintra = 1,
    forceidr = 2,
    output_spspps = 4,
    eos = 8,
};

pub const PicStruct = enum(c_uint) {
    rame = 1,
    ield_top_bottom = 2,
    ield_bottom_top = 3,
};

pub const PicType = enum(c_uint) {
    p = 0,
    b = 1,
    i = 2,
    idr = 3,
    bi = 4,
    skipped = 5,
    intra_refresh = 6,
    nonref_p = 7,
    unknown = 255,
};

pub const QPMapMode = enum(c_uint) {
    disabled = 0,
    emphasis = 1,
    delta = 2,
};

pub const Status = enum(c_uint) {
    success = 0,
    no_encode_device = 1,
    unsupported_device = 2,
    invalid_encoderdevice = 3,
    invalid_device = 4,
    device_not_exist = 5,
    invalid_ptr = 6,
    invalid_event = 7,
    invalid_param = 8,
    invalid_call = 9,
    out_of_memory = 10,
    encoder_not_initialized = 11,
    unsupported_param = 12,
    lock_busy = 13,
    not_enough_buffer = 14,
    invalid_version = 15,
    map_failed = 16,
    need_more_input = 17,
    encoder_busy = 18,
    event_not_registerd = 19,
    generic = 20,
    incompatible_client_key = 21,
    unimplemented = 22,
    resource_register_failed = 23,
    resource_not_registered = 24,
    resource_not_mapped = 25,
};

pub const StereoPackingMode = enum(c_uint) {
    none = 0,
    checkerboard = 1,
    colinterleave = 2,
    rowinterleave = 3,
    sidebyside = 4,
    topbottom = 5,
    frameseq = 6,
};

pub const TuningInfo = enum(c_uint) {
    undefined = 0,
    high_quality = 1,
    low_latency = 2,
    ultra_low_latency = 3,
    lossless = 4,
};

pub const InputPtr = ?*opaque {};
pub const OutputPtr = ?*opaque {};
pub const RegisteredPtr = ?*opaque {};
pub const CustreamPtr = ?*opaque {};

pub const CodecConfig = extern union {
    h264Config: ConfigH264,
    hevcConfig: ConfigHEVC,
    h264MeOnlyConfig: ConfigH264MeOnly,
    hevcMeOnlyConfig: ConfigHEVCMeOnly,
    _reserved: [320]u32,
};

pub const CodecPicParams = extern union {
    h264PicParams: PicParamsH264,
    hevcPicParams: PicParamsHEVC,
    _reserved: [256]u32,
};

pub const Config = extern struct {
    version: u32,
    profileGUID: GUID,
    gopLength: u32,
    frameIntervalP: i32,
    monoChromeEncoding: u32,
    frameFieldMode: ParamsFrameFieldMode,
    mvPrecision: MVPrecision,
    rcParams: RcParams,
    encodeCodecConfig: CodecConfig,
    _reserved: [278]u32,
    _reserved2: [64]?*anyopaque,
};

pub const ConfigH264 = extern struct {
    bitfields: packed struct {
        _reserved1: bool,
        enableStereoMVC: bool,
        hierarchicalPFrames: bool,
        hierarchicalBFrames: bool,
        outputBufferingPeriodSEI: bool,
        outputPictureTimingSEI: bool,
        outputAUD: bool,
        disableSPSPPS: bool,
        outputFramePackingSEI: bool,
        outputRecoveryPointSEI: bool,
        enableIntraRefresh: bool,
        enableConstrainedEncoding: bool,
        repeatSPSPPS: bool,
        enableVFR: bool,
        enableLTR: bool,
        qpPrimeYZeroTransformBypassFlag: bool,
        useConstrainedIntraPred: bool,
        enableFillerDataInsertion: bool,
        _reserved2: u14,
    },
    level: u32,
    idrPeriod: u32,
    separateColourPlaneFlag: u32,
    disableDeblockingFilterIDC: u32,
    numTemporalLayers: u32,
    spsId: u32,
    ppsId: u32,
    adaptiveTransformMode: H264AdaptiveTransformMode,
    fmoMode: H264FMOMode,
    bdirectMode: H264BDirectMode,
    entropyCodingMode: H264EntropyCodingMode,
    stereoMode: StereoPackingMode,
    intraRefreshPeriod: u32,
    intraRefreshCnt: u32,
    maxNumRefFrames: u32,
    sliceMode: u32,
    sliceModeData: u32,
    h264VUIParameters: ConfigH264VuiParameters,
    ltrNumFrames: u32,
    ltrTrustMode: u32,
    chromaFormatIDC: u32,
    maxTemporalLayers: u32,
    useBFramesAsRef: BFrameRefMode,
    numRefL0: NumRefFrames,
    numRefL1: NumRefFrames,
    _reserved1: [267]u32,
    _reserved2: [64]?*anyopaque,
};

pub const ConfigH264MeOnly = extern struct {
    bitFlags1: u32,
    _reserved1: [255]u32,
    _reserved2: [64]?*anyopaque,
};

pub const ConfigH264VuiParameters = extern struct {
    overscanInfoPresentFlag: u32,
    overscanInfo: u32,
    videoSignalTypePresentFlag: u32,
    videoFormat: u32,
    videoFullRangeFlag: u32,
    colourDescriptionPresentFlag: u32,
    colourPrimaries: u32,
    transferCharacteristics: u32,
    colourMatrix: u32,
    chromaSampleLocationFlag: u32,
    chromaSampleLocationTop: u32,
    chromaSampleLocationBot: u32,
    bitstreamRestrictionFlag: u32,
    _reserved: [15]u32,
};

pub const ConfigHEVCVuiParameters = extern struct {
    overscanInfoPresentFlag: u32,
    overscanInfo: u32,
    videoSignalTypePresentFlag: u32,
    videoFormat: u32,
    videoFullRangeFlag: u32,
    colourDescriptionPresentFlag: u32,
    colourPrimaries: u32,
    transferCharacteristics: u32,
    colourMatrix: u32,
    chromaSampleLocationFlag: u32,
    chromaSampleLocationTop: u32,
    chromaSampleLocationBot: u32,
    bitstreamRestrictionFlag: u32,
    _reserved: [15]u32,
};

pub const ConfigHEVC = extern struct {
    level: u32,
    tier: u32,
    minCUSize: HEVCCusize,
    maxCUSize: HEVCCusize,
    bitfields: packed struct {
        useConstrainedIntraPred: bool,
        disableDeblockAcrossSliceBoundary: bool,
        outputBufferingPeriodSEI: bool,
        outputPictureTimingSEI: bool,
        outputAUD: bool,
        enableLTR: bool,
        disableSPSPPS: bool,
        repeatSPSPPS: bool,
        enableIntraRefresh: bool,
        chromaFormatIDC: u2,
        pixelBitDepthMinus8: u3,
        enableFillerDataInsetion: bool,
        enableConstrainedEncoding: bool,
        _reserved: u16,
    },
    idrPeriod: u32,
    intraRefreshPeriod: u32,
    intraRefreshCnt: u32,
    maxNumRefFramesInDPB: u32,
    ltrNumFrames: u32,
    vpsId: u32,
    spsId: u32,
    ppsId: u32,
    sliceMode: u32,
    sliceModeData: u32,
    maxTemporalLayersMinus1: u32,
    hevcVUIParameters: ConfigHEVCVuiParameters,
    ltrTrustMode: u32,
    useBFramesAsRef: BFrameRefMode,
    numRefL0: NumRefFrames,
    numRefL1: NumRefFrames,
    _reserved1: [214]u32,
    _reserved2: [64]?*anyopaque,
};

pub const ConfigHEVCMeOnly = extern struct {
    _reserved: [256]u32,
    _reserved1: [64]?*anyopaque,
};

pub const CreateBitstreamBuffer = extern struct {
    version: u32,
    size: u32,
    memoryHeap: MemoryHeap,
    _reserved: u32,
    bitstreamBuffer: OutputPtr,
    bitstreamBufferPtr: ?*anyopaque,
    _reserved1: [58]u32,
    _reserved2: [64]?*anyopaque,
};

pub const CreateInputBuffer = extern struct {
    version: u32,
    width: u32,
    height: u32,
    memoryHeap: MemoryHeap,
    bufferFmt: BufferFormat,
    _reserved: u32,
    inputBuffer: InputPtr,
    pSysMemBuffer: ?*anyopaque,
    _reserved1: [57]u32,
    _reserved2: [63]?*anyopaque,
};

pub const ExternalMeHint = extern struct {
    _reserved: i32,
};

pub const ExternalMeHintCountsPerBlocktype = extern struct {
    _reserved: u32,
    _reserved1: [3]u32,
};

pub const GUID = extern struct {
    Data1: u32,
    Data2: u16,
    Data3: u16,
    Data4: [8]u8,
};

pub const InitializeParams = extern struct {
    version: u32,
    encodeGUID: GUID,
    presetGUID: GUID,
    encodeWidth: u32,
    encodeHeight: u32,
    darWidth: u32,
    darHeight: u32,
    frameRateNum: u32,
    frameRateDen: u32,
    enableEncodeAsync: u32,
    enablePTD: u32,
    bitFlags1: u32,
    privDataSize: u32,
    privData: ?*anyopaque,
    encodeConfig: ?*Config,
    maxEncodeWidth: u32,
    maxEncodeHeight: u32,
    maxMEHintCountsPerBlock: [2]ExternalMeHintCountsPerBlocktype,
    tuningInfo: TuningInfo,
    _reserved: [288]u32,
    _reserved2: [64]?*anyopaque,
};

pub const LockBitstream = extern struct {
    version: u32,
    bitFlags1: u32,
    outputBitstream: ?*anyopaque,
    sliceOffsets: [*c]u32,
    frameIdx: u32,
    hwEncodeStatus: u32,
    numSlices: u32,
    bitstreamSizeInBytes: u32,
    outputTimeStamp: u64,
    outputDuration: u64,
    bitstreamBufferPtr: ?*anyopaque,
    pictureType: PicType,
    pictureStruct: PicStruct,
    frameAvgQP: u32,
    frameSatd: u32,
    ltrFrameIdx: u32,
    ltrFrameBitmap: u32,
    _reserved: [13]u32,
    intraMBCount: u32,
    interMBCount: u32,
    averageMVX: i32,
    averageMVY: i32,
    _reserved1: [219]u32,
    _reserved2: [64]?*anyopaque,
};

pub const LockInputBuffer = extern struct {
    version: u32,
    bitFlags1: u32,
    inputBuffer: InputPtr,
    bufferDataPtr: ?*anyopaque,
    pitch: u32,
    _reserved1: [251]u32,
    _reserved2: [64]?*anyopaque,
};

pub const MapInputResource = extern struct {
    version: u32,
    subResourceIndex: u32,
    inputResource: ?*anyopaque,
    registeredResource: RegisteredPtr,
    mappedResource: InputPtr,
    mappedBufferFmt: BufferFormat,
    _reserved1: [251]u32,
    _reserved2: [63]?*anyopaque,
};

pub const OpenEncodeSessionExParams = extern struct {
    version: u32,
    deviceType: DeviceType,
    device: ?*anyopaque,
    _reserved: ?*anyopaque,
    apiVersion: u32,
    _reserved1: [253]u32,
    _reserved2: [64]?*anyopaque,
};

pub const PicParams = extern struct {
    version: u32,
    inputWidth: u32,
    inputHeight: u32,
    inputPitch: u32,
    encodePicFlags: u32,
    frameIdx: u32,
    inputTimeStamp: u64,
    inputDuration: u64,
    inputBuffer: InputPtr,
    outputBitstream: OutputPtr,
    completionEvent: ?*anyopaque,
    bufferFmt: BufferFormat,
    pictureStruct: PicStruct,
    pictureType: PicType,
    codecPicParams: CodecPicParams,
    meHintCountsPerBlock: [2]ExternalMeHintCountsPerBlocktype,
    meExternalHints: ?*ExternalMeHint,
    _reserved1: [6]u32,
    _reserved2: [2]?*anyopaque,
    qpDeltaMap: [*c]i8,
    qpDeltaMapSize: u32,
    _reservedBitFields: u32,
    meHintRefPicDist: [2]u16,
    _reserved3: [286]u32,
    _reserved4: [60]?*anyopaque,
};

pub const PicParamsH264 = extern struct {
    displayPOCSyntax: u32,
    _reserved3: u32,
    refPicFlag: u32,
    colourPlaneId: u32,
    forceIntraRefreshWithFrameCnt: u32,
    bitFlags1: u32,
    sliceTypeData: [*c]u8,
    sliceTypeArrayCnt: u32,
    seiPayloadArrayCnt: u32,
    seiPayloadArray: [*c]SeiPayload,
    sliceMode: u32,
    sliceModeData: u32,
    ltrMarkFrameIdx: u32,
    ltrUseFrameBitmap: u32,
    ltrUsageMode: u32,
    forceIntraSliceCount: u32,
    forceIntraSliceIdx: [*c]u32,
    h264ExtPicParams: PicParamsH264Ext,
    _reserved: [210]u32,
    _reserved2: [61]?*anyopaque,
};

pub const PicParamsMVC = extern struct {
    version: u32,
    viewID: u32,
    temporalID: u32,
    priorityID: u32,
    _reserved1: [12]u32,
    _reserved2: [8]?*anyopaque,
};

pub const PicParamsH264Ext = extern union {
    mvcPicParams: PicParamsMVC,
    _reserved1: [32]u32,
};

pub const PicParamsHEVC = extern struct {
    displayPOCSyntax: u32,
    refPicFlag: u32,
    temporalId: u32,
    forceIntraRefreshWithFrameCnt: u32,
    bitFlags1: u32,
    sliceTypeData: [*c]u8,
    sliceTypeArrayCnt: u32,
    sliceMode: u32,
    sliceModeData: u32,
    ltrMarkFrameIdx: u32,
    ltrUseFrameBitmap: u32,
    ltrUsageMode: u32,
    seiPayloadArrayCnt: u32,
    _reserved: u32,
    seiPayloadArray: [*c]SeiPayload,
    _reserved2: [244]u32,
    _reserved3: [61]?*anyopaque,
};

pub const PresetConfig = extern struct {
    version: u32,
    presetCfg: Config,
    _reserved1: [255]u32,
    _reserved2: [64]?*anyopaque,
};

// XXX: In the original headers the struct values are unsigned integers. As
// explained in the docs, this is for legacy reasons and the user must treat
// them as if they were i32. We took the liberty to declare them i32 here as a
// convenience.
pub const Qp = extern struct {
    qpInterP: i32,
    qpInterB: i32,
    qpIntra: i32,
};

pub const RcParams = extern struct {
    version: u32,
    rateControlMode: ParamsRcMode,
    constQP: Qp,
    averageBitRate: u32,
    maxBitRate: u32,
    vbvBufferSize: u32,
    vbvInitialDelay: u32,
    bitFlags1: u32,
    minQP: Qp,
    maxQP: Qp,
    initialRCQP: Qp,
    temporallayerIdxMask: u32,
    temporalLayerQP: [8]u8,
    targetQuality: u8,
    targetQualityLSB: u8,
    lookaheadDepth: u16,
    lowDelayKeyFrameScale: u8,
    _reserved1: [3]u8,
    qpMapMode: QPMapMode,
    multiPass: MultiPass,
    _reserved: [6]u32,
};

pub const RegisterResource = extern struct {
    version: u32,
    resourceType: InputResourceType,
    width: u32,
    height: u32,
    pitch: u32,
    subResourceIndex: u32,
    resourceToRegister: ?*anyopaque,
    registeredResource: RegisteredPtr,
    bufferFormat: BufferFormat,
    bufferUsage: BufferUsage,
    _reserved1: [247]u32,
    _reserved2: [62]?*anyopaque,
};

pub const SeiPayload = extern struct {
    payloadSize: u32,
    payloadType: u32,
    payload: [*c]u8,
};

pub const SequenceParamPayload = extern struct {
    version: u32,
    inBufferSize: u32,
    spsId: u32,
    ppsId: u32,
    spsppsBuffer: ?*anyopaque,
    outSPSPPSPayloadSize: [*c]u32,
    _reserved: [250]u32,
    _reserved2: [64]?*anyopaque,
};

pub const ApiFunctionList = extern struct {
    version: u32,
    reserved: u32,
    __nvEncOpenEncodeSession: ?*const fn (?*anyopaque, u32, ?*?*anyopaque) callconv(.C) Status, // deprecated
    __nvEncGetEncodeGUIDCount: ?*anyopaque, // not included in bindings
    __nvEncGetEncodeProfileGUIDCount: ?*anyopaque, // not included in bindings,
    __nvEncGetEncodeProfileGUIDs: ?*anyopaque, // not included in bindings
    __nvEncGetEncodeGUIDs: ?*anyopaque, // not included in bindings
    __nvEncGetInputFormatCount: ?*anyopaque, // not included in bindings
    __nvEncGetInputFormats: ?*anyopaque, // not included in bindings
    __nvEncGetEncodeCaps: ?*anyopaque, // not included in bindings
    __nvEncGetEncodePresetCount: ?*anyopaque, // not included in bindings
    __nvEncGetEncodePresetGUIDs: ?*anyopaque, // not included in bindings
    nvEncGetEncodePresetConfig: ?*const fn (?*anyopaque, GUID, GUID, ?*PresetConfig) Status,
    nvEncInitializeEncoder: ?*const fn (?*anyopaque, ?*InitializeParams) callconv(.C) Status,
    nvEncCreateInputBuffer: ?*const fn (?*anyopaque, ?*CreateInputBuffer) callconv(.C) Status,
    nvEncDestroyInputBuffer: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status,
    nvEncCreateBitstreamBuffer: ?*const fn (?*anyopaque, ?*CreateBitstreamBuffer) callconv(.C) Status,
    nvEncDestroyBitstreamBuffer: ?*const fn (?*anyopaque, OutputPtr) callconv(.C) Status,
    nvEncEncodePicture: ?*const fn (?*anyopaque, ?*PicParams) callconv(.C) Status,
    nvEncLockBitstream: ?*const fn (?*anyopaque, ?*LockBitstream) callconv(.C) Status,
    nvEncUnlockBitstream: ?*const fn (?*anyopaque, OutputPtr) callconv(.C) Status,
    nvEncLockInputBuffer: ?*const fn (?*anyopaque, ?*LockInputBuffer) callconv(.C) Status,
    nvEncUnlockInputBuffer: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status,
    __nvEncGetEncodeStats: ?*anyopaque, // not included in bindings
    nvEncGetSequenceParams: ?*const fn (?*anyopaque, ?*SequenceParamPayload) callconv(.C) Status,
    __nvEncRegisterAsyncEvent: ?*anyopaque, // not included in bindings
    __nvEncUnregisterAsyncEvent: ?*anyopaque, // not included in bindings
    nvEncMapInputResource: ?*const fn (?*anyopaque, ?*MapInputResource) callconv(.C) Status,
    nvEncUnmapInputResource: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status,
    nvEncDestroyEncoder: ?*const fn (?*anyopaque) callconv(.C) Status,
    __nvEncInvalidateRefFrames: ?*anyopaque, // not included in bindings
    nvEncOpenEncodeSessionEx: ?*const fn (?*OpenEncodeSessionExParams, ?*?*anyopaque) callconv(.C) Status,
    nvEncRegisterResource: ?*const fn (?*anyopaque, ?*RegisterResource) callconv(.C) Status,
    nvEncUnregisterResource: ?*const fn (?*anyopaque, RegisteredPtr) callconv(.C) Status,
    __nvEncReconfigureEncoder: ?*anyopaque, // not included in bindings
    _reserved1: ?*anyopaque,
    __nvEncCreateMVBuffer: ?*anyopaque, // not included in bindings
    __nvEncDestroyMVBuffer: ?*anyopaque, // not included in bindings
    __nvEncRunMotionEstimationOnly: ?*anyopaque, // not included in bindings
    nvEncGetLastErrorString: ?*const fn (?*anyopaque) callconv(.C) [*c]const u8,
    nvEncSetIOCudaStreams: ?*const fn (?*anyopaque, CustreamPtr, CustreamPtr) Status,
    nvEncGetEncodePresetConfigEx: ?*const fn (?*anyopaque, GUID, GUID, TuningInfo, ?*PresetConfig) Status,
    __nvEncGetSequenceParamEx: ?*const fn (?*anyopaque, ?*InitializeParams, ?*SequenceParamPayload) callconv(.C) Status, // not included in bindings
    __nvEncSetIOCudaStreams: ?*anyopaque, // not included in bindings
    _reserved2: [279]?*anyopaque,
};

pub var nvEncGetEncodePresetConfig: ?*const fn (?*anyopaque, GUID, GUID, ?*PresetConfig) Status = null;
pub var nvEncInitializeEncoder: ?*const fn (?*anyopaque, ?*InitializeParams) callconv(.C) Status = null;
pub var nvEncCreateInputBuffer: ?*const fn (?*anyopaque, ?*CreateInputBuffer) callconv(.C) Status = null;
pub var nvEncDestroyInputBuffer: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status = null;
pub var nvEncCreateBitstreamBuffer: ?*const fn (?*anyopaque, ?*CreateBitstreamBuffer) callconv(.C) Status = null;
pub var nvEncDestroyBitstreamBuffer: ?*const fn (?*anyopaque, OutputPtr) callconv(.C) Status = null;
pub var nvEncEncodePicture: ?*const fn (?*anyopaque, ?*PicParams) callconv(.C) Status = null;
pub var nvEncLockBitstream: ?*const fn (?*anyopaque, ?*LockBitstream) callconv(.C) Status = null;
pub var nvEncUnlockBitstream: ?*const fn (?*anyopaque, OutputPtr) callconv(.C) Status = null;
pub var nvEncLockInputBuffer: ?*const fn (?*anyopaque, ?*LockInputBuffer) callconv(.C) Status = null;
pub var nvEncUnlockInputBuffer: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status = null;
pub var nvEncGetSequenceParams: ?*const fn (?*anyopaque, ?*SequenceParamPayload) callconv(.C) Status = null;
pub var nvEncMapInputResource: ?*const fn (?*anyopaque, ?*MapInputResource) callconv(.C) Status = null;
pub var nvEncUnmapInputResource: ?*const fn (?*anyopaque, InputPtr) callconv(.C) Status = null;
pub var nvEncDestroyEncoder: ?*const fn (?*anyopaque) callconv(.C) Status = null;
pub var nvEncOpenEncodeSessionEx: ?*const fn (?*OpenEncodeSessionExParams, ?*?*anyopaque) callconv(.C) Status = null;
pub var nvEncRegisterResource: ?*const fn (?*anyopaque, ?*RegisterResource) callconv(.C) Status = null;
pub var nvEncUnregisterResource: ?*const fn (?*anyopaque, RegisteredPtr) callconv(.C) Status = null;
pub var nvEncGetLastErrorString: ?*const fn (?*anyopaque) callconv(.C) [*c]const u8 = null;
pub var nvEncSetIOCudaStreams: ?*const fn (?*anyopaque, CustreamPtr, CustreamPtr) Status = null;
pub var nvEncGetEncodePresetConfigEx: ?*const fn (?*anyopaque, GUID, GUID, TuningInfo, ?*PresetConfig) Status = null;

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub fn load() !void {
    const std = @import("std");
    const builtin = @import("builtin");

    var dylib = try switch (builtin.target.os.tag) {
        .linux, .macos => std.DynLib.open("libnvidia-encode.so.1"),
        .windows => switch (builtin.target.cpu.arch) {
            .x86 => std.DynLib.open("nvEncodeAPI.dll"),
            .x86_64 => std.DynLib.open("nvEncodeAPI64.dll"),
            else => @compileError("unsupported architecture"),
        },
        else => @compileError("unsupported operating system"),
    };

    const NvEncodeAPIGetMaxSupportedVersion = dylib.lookup(*const fn (version: *u32) Status, "NvEncodeAPIGetMaxSupportedVersion") orelse @panic("invalid libnvidia-encode");
    var version_lib: u32 = 0;
    if (NvEncodeAPIGetMaxSupportedVersion(&version_lib) != .success)
        @panic("NvEncodeAPIGetMaxSupportedVersion failed");
    if (((api_major_version << 4) | api_minor_version) > version_lib)
        return error.DriverVersionTooOld;

    const NvEncodeAPICreateInstance = dylib.lookup(*const fn (functionList: ?*ApiFunctionList) Status, "NvEncodeAPICreateInstance") orelse @panic("invalid libnvidia-encode");
    var function_list = std.mem.zeroes(ApiFunctionList);
    function_list.version = api_function_list_ver;
    if (NvEncodeAPICreateInstance(&function_list) != .success)
        @panic("NvEncodeAPICreateInstance failed");

    nvEncGetEncodePresetConfig = function_list.nvEncGetEncodePresetConfig;
    nvEncInitializeEncoder = function_list.nvEncInitializeEncoder;
    nvEncCreateInputBuffer = function_list.nvEncCreateInputBuffer;
    nvEncDestroyInputBuffer = function_list.nvEncDestroyInputBuffer;
    nvEncCreateBitstreamBuffer = function_list.nvEncCreateBitstreamBuffer;
    nvEncDestroyBitstreamBuffer = function_list.nvEncDestroyBitstreamBuffer;
    nvEncEncodePicture = function_list.nvEncEncodePicture;
    nvEncLockBitstream = function_list.nvEncLockBitstream;
    nvEncUnlockBitstream = function_list.nvEncUnlockBitstream;
    nvEncLockInputBuffer = function_list.nvEncLockInputBuffer;
    nvEncUnlockInputBuffer = function_list.nvEncUnlockInputBuffer;
    nvEncGetSequenceParams = function_list.nvEncGetSequenceParams;
    nvEncMapInputResource = function_list.nvEncMapInputResource;
    nvEncUnmapInputResource = function_list.nvEncUnmapInputResource;
    nvEncDestroyEncoder = function_list.nvEncDestroyEncoder;
    nvEncOpenEncodeSessionEx = function_list.nvEncOpenEncodeSessionEx;
    nvEncRegisterResource = function_list.nvEncRegisterResource;
    nvEncUnregisterResource = function_list.nvEncUnregisterResource;
    nvEncGetLastErrorString = function_list.nvEncGetLastErrorString;
    nvEncSetIOCudaStreams = function_list.nvEncSetIOCudaStreams;
    nvEncGetEncodePresetConfigEx = function_list.nvEncGetEncodePresetConfigEx;
}
