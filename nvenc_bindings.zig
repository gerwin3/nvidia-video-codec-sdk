pub const api_major_version = 9;
pub const api_minor_version = 0;
pub const api_version = api_major_version | (api_minor_version << 24);

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

pub const MVPrecision = enum(c_uint) {
    default = 0,
    full_pel = 1,
    half_pel = 2,
    quarter_pel = 3,
};

pub const MemoryHeap = enum(c_uint) {
    autoselect = 0,
    vid = 1,
    sysmem_cached = 2,
    sysmem_uncached = 3,
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
    cbr_lowdelay_hq = 8,
    cbr_hq = 16,
    vbr_hq = 32,
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

pub const InputPtr = ?*anyopaque;
pub const OutputPtr = ?*anyopaque;

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
    bitFlags1: u32,
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
    _reserved1: [269]u32,
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
    bitFlags1: u32,
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
    _reserved1: [216]u32,
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
    _reserved: [289]u32,
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
    _reserved: [242]u32,
    _reserved2: [61]?*anyopaque,
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

pub const Qp = extern struct {
    qpInterP: u32,
    qpInterB: u32,
    qpIntra: u32,
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
    _reserved1: u32,
    qpMapMode: QPMapMode,
    _reserved: [7]u32,
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
    __nvEncGetEncodePresetConfig: ?*anyopaque, // not included in bindings
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
    __nvEncMapInputResource: ?*anyopaque, // not included in bindings
    __nvEncUnmapInputResource: ?*anyopaque, // not included in bindings
    nvEncDestroyEncoder: ?*const fn (?*anyopaque) callconv(.C) Status,
    __nvEncInvalidateRefFrames: ?*anyopaque, // not included in bindings
    nvEncOpenEncodeSessionEx: ?*const fn (?*OpenEncodeSessionExParams, ?*?*anyopaque) callconv(.C) Status,
    __nvEncRegisterResource: ?*anyopaque, // not included in bindings
    __nvEncUnregisterResource: ?*anyopaque, // not included in bindings
    __nvEncReconfigureEncoder: ?*anyopaque, // not included in bindings
    _reserved1: ?*anyopaque,
    __nvEncCreateMVBuffer: ?*anyopaque, // not included in bindings
    __nvEncDestroyMVBuffer: ?*anyopaque, // not included in bindings
    __nvEncRunMotionEstimationOnly: ?*anyopaque, // not included in bindings
    nvEncGetLastErrorString: ?*const fn (?*anyopaque) callconv(.C) [*c]const u8,
    nvEncSetIOCudaStreams: ?*anyopaque, // not included in bindings
    _reserved2: [279]?*anyopaque,
};

pub extern fn NvEncodeAPICreateInstance(functionList: ?*ApiFunctionList) Status;
