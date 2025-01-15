pub const cuda_bindings = @import("cuda_bindings");

pub const DecodeStatus = enum(c_uint) {
    invalid = 0,
    in_progress = 1,
    success = 2,
    err = 8,
    err_concealed = 9,
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

pub const VideoChromaFormat = enum(c_int) {
    monochrome = 0,
    @"420" = 1,
    @"422" = 2,
    @"444" = 3,
};

pub const VideoCodec = enum(c_uint) {
    mpeg1 = 0,
    mpeg2 = 1,
    mpeg4 = 2,
    vc1 = 3,
    h264 = 4,
    jpeg = 5,
    h264_svc = 6,
    h264_mvc = 7,
    hevc = 8,
    vp8 = 9,
    vp9 = 10,
    numcodecs = 11,
    yuv420 = 1230591318,
    yv12 = 1498820914,
    nv12 = 1314271538,
    yuyv = 1498765654,
    uyvy = 1431918169,
};

pub const VideoDeinterlaceMode = enum(c_int) {
    weave = 0,
    bob = 1,
    adaptive = 2,
};

pub const VideoSurfaceFormat = enum(c_uint) {
    nv12 = 0,
    p016 = 1,
    yuv444 = 2,
    yuv444_16bit = 3,
};

pub const VideoParser = ?*opaque {};
pub const VideoDecoder = ?*opaque {};
pub const VideoCtxLock = ?*opaque {};

pub const VideoTimestamp = c_longlong;

pub const packet_flags = struct {
    pub const endofstream: c_uint = 1;
    pub const timestamp: c_uint = 2;
    pub const discontinuity: c_uint = 4;
    pub const endofpicture: c_uint = 8;
    pub const notify_eos: c_uint = 16;
};

pub const create_flags = struct {
    pub const default: c_uint = 0;
    pub const prefer_CUDA: c_uint = 1;
    pub const prefer_DXVA: c_uint = 2;
    pub const prefer_CUVID: c_uint = 4;
};

pub const CreateInfo = extern struct {
    ulWidth: c_ulong,
    ulHeight: c_ulong,
    ulNumDecodeSurfaces: c_ulong,
    CodecType: VideoCodec,
    ChromaFormat: VideoChromaFormat,
    ulCreationFlags: c_ulong,
    bitDepthMinus8: c_ulong,
    ulIntraDecodeOnly: c_ulong,
    ulMaxWidth: c_ulong,
    ulMaxHeight: c_ulong,
    _Reserved1: c_ulong,
    display_area: extern struct {
        left: c_short,
        top: c_short,
        right: c_short,
        bottom: c_short,
    },
    OutputFormat: VideoSurfaceFormat,
    DeinterlaceMode: VideoDeinterlaceMode,
    ulTargetWidth: c_ulong,
    ulTargetHeight: c_ulong,
    ulNumOutputSurfaces: c_ulong,
    vidLock: VideoCtxLock,
    target_rect: extern struct {
        left: c_short,
        top: c_short,
        right: c_short,
        bottom: c_short,
    },
    _Reserved2: [5]c_ulong,
};

pub const DecodeCaps = extern struct {
    eCodecType: VideoCodec,
    eChromaFormat: VideoChromaFormat,
    nBitDepthMinus8: c_uint,
    _reserved1: [3]c_uint,
    bIsSupported: u8,
    _reserved2: u8,
    nOutputFormatMask: c_ushort,
    nMaxWidth: c_uint,
    nMaxHeight: c_uint,
    nMaxMBCount: c_uint,
    nMinWidth: c_ushort,
    nMinHeight: c_ushort,
    _reserved3: [11]c_uint,
};

pub const GetDecodeStatus = extern struct {
    decodeStatus: DecodeStatus,
    reserved: [31]c_uint,
    _pReserved: [8]?*anyopaque,
};

pub const H264DPBEntry = extern struct {
    PicIdx: c_int,
    FrameIdx: c_int,
    is_long_term: c_int,
    not_existing: c_int,
    used_for_reference: c_int,
    FieldOrderCnt: [2]c_int,
};

pub const H264MVCExt = extern struct {
    num_views_minus1: c_int,
    view_id: c_int,
    inter_view_flag: u8,
    num_inter_view_refs_l0: u8,
    num_inter_view_refs_l1: u8,
    MVCReserved8Bits: u8,
    InterViewRefsL0: [16]c_int,
    InterViewRefsL1: [16]c_int,
};

pub const H264SVCExt = extern struct {
    profile_idc: u8,
    level_idc: u8,
    DQId: u8,
    DQIdMax: u8,
    disable_inter_layer_deblocking_filter_idc: u8,
    ref_layer_chroma_phase_y_plus1: u8,
    inter_layer_slice_alpha_c0_offset_div2: i8,
    inter_layer_slice_beta_offset_div2: i8,
    DPBEntryValidFlag: c_ushort,
    inter_layer_deblocking_filter_control_present_flag: u8,
    extended_spatial_scalability_idc: u8,
    adaptive_tcoeff_level_prediction_flag: u8,
    slice_header_restriction_flag: u8,
    chroma_phase_x_plus1_flag: u8,
    chroma_phase_y_plus1: u8,
    tcoeff_level_prediction_flag: u8,
    constrained_intra_resampling_flag: u8,
    ref_layer_chroma_phase_x_plus1_flag: u8,
    store_ref_base_pic_flag: u8,
    _Reserved8BitsA: u8,
    _Reserved8BitsB: u8,
    scaled_ref_layer_left_offset: c_short,
    scaled_ref_layer_top_offset: c_short,
    scaled_ref_layer_right_offset: c_short,
    scaled_ref_layer_bottom_offset: c_short,
    _Reserved16Bits: c_ushort,
    pNextLayer: ?*PicParams,
    bRefBaseLayer: c_int,
};

pub const ParserDispInfo = extern struct {
    picture_index: c_int,
    progressive_frame: c_int,
    top_field_first: c_int,
    repeat_first_field: c_int,
    timestamp: VideoTimestamp,
};

pub const ParserParams = extern struct {
    CodecType: VideoCodec,
    ulMaxNumDecodeSurfaces: c_uint,
    ulClockRate: c_uint,
    ulErrorThreshold: c_uint,
    ulMaxDisplayDelay: c_uint,
    uReserved1: [5]c_uint,
    pUserData: ?*anyopaque,
    pfnSequenceCallback: ?*const fn (?*anyopaque, ?*VideoFormat) callconv(.C) c_int,
    pfnDecodePicture: ?*const fn (?*anyopaque, ?*PicParams) callconv(.C) c_int,
    pfnDisplayPicture: ?*const fn (?*anyopaque, ?*ParserDispInfo) callconv(.C) c_int,
    pvReserved2: [7]?*anyopaque,
    pExtVideoInfo: ?*VideoFormatEx,
};

pub const PicParams = extern struct {
    PicWidthInMbs: c_int,
    FrameHeightInMbs: c_int,
    CurrPicIdx: c_int,
    field_pic_flag: c_int,
    bottom_field_flag: c_int,
    second_field: c_int,
    nBitstreamDataLen: c_uint,
    pBitstreamData: [*c]const u8,
    nNumSlices: c_uint,
    pSliceDataOffsets: [*c]const c_uint,
    ref_pic_flag: c_int,
    intra_pic_flag: c_int,
    _Reserved: [30]c_uint,
    CodecSpecific: extern union {
        mpeg2: MPEG2PicParams,
        h264: H264PicParams,
        vc1: VC1PicParams,
        mpeg4: MPEG4PicParams,
        jpeg: JPEGPicParams,
        hevc: HEVCPicParams,
        vp8: VP8PicParams,
        vp9: VP9PicParams,
        _CodecReserved: [1024]c_uint,
    },
};

pub const H264PicParams = extern struct {
    log2_max_frame_num_minus4: c_int,
    pic_order_cnt_type: c_int,
    log2_max_pic_order_cnt_lsb_minus4: c_int,
    delta_pic_order_always_zero_flag: c_int,
    frame_mbs_only_flag: c_int,
    direct_8x8_inference_flag: c_int,
    num_ref_frames: c_int,
    residual_colour_transform_flag: u8,
    bit_depth_luma_minus8: u8,
    bit_depth_chroma_minus8: u8,
    qpprime_y_zero_transform_bypass_flag: u8,
    entropy_coding_mode_flag: c_int,
    pic_order_present_flag: c_int,
    num_ref_idx_l0_active_minus1: c_int,
    num_ref_idx_l1_active_minus1: c_int,
    weighted_pred_flag: c_int,
    weighted_bipred_idc: c_int,
    pic_init_qp_minus26: c_int,
    deblocking_filter_control_present_flag: c_int,
    redundant_pic_cnt_present_flag: c_int,
    transform_8x8_mode_flag: c_int,
    MbaffFrameFlag: c_int,
    constrained_intra_pred_flag: c_int,
    chroma_qp_index_offset: c_int,
    second_chroma_qp_index_offset: c_int,
    ref_pic_flag: c_int,
    frame_num: c_int,
    CurrFieldOrderCnt: [2]c_int,
    dpb: [16]H264DPBEntry,
    WeightScale4x4: [6][16]u8,
    WeightScale8x8: [2][64]u8,
    fmo_aso_enable: u8,
    num_slice_groups_minus1: u8,
    slice_group_map_type: u8,
    pic_init_qs_minus26: i8,
    slice_group_change_rate_minus1: c_uint,
    fmo: extern union {
        slice_group_map_addr: u64,
        pMb2SliceGroupMap: [*c]const u8,
    },
    _Reserved: [12]c_uint,
    ext: extern union {
        mvcext: H264MVCExt,
        svcext: H264SVCExt,
    },
};

pub const HEVCPicParams = extern struct {
    pic_width_in_luma_samples: c_int,
    pic_height_in_luma_samples: c_int,
    log2_min_luma_coding_block_size_minus3: u8,
    log2_diff_max_min_luma_coding_block_size: u8,
    log2_min_transform_block_size_minus2: u8,
    log2_diff_max_min_transform_block_size: u8,
    pcm_enabled_flag: u8,
    log2_min_pcm_luma_coding_block_size_minus3: u8,
    log2_diff_max_min_pcm_luma_coding_block_size: u8,
    pcm_sample_bit_depth_luma_minus1: u8,
    pcm_sample_bit_depth_chroma_minus1: u8,
    pcm_loop_filter_disabled_flag: u8,
    strong_intra_smoothing_enabled_flag: u8,
    max_transform_hierarchy_depth_intra: u8,
    max_transform_hierarchy_depth_inter: u8,
    amp_enabled_flag: u8,
    separate_colour_plane_flag: u8,
    log2_max_pic_order_cnt_lsb_minus4: u8,
    num_short_term_ref_pic_sets: u8,
    long_term_ref_pics_present_flag: u8,
    num_long_term_ref_pics_sps: u8,
    sps_temporal_mvp_enabled_flag: u8,
    sample_adaptive_offset_enabled_flag: u8,
    scaling_list_enable_flag: u8,
    IrapPicFlag: u8,
    IdrPicFlag: u8,
    bit_depth_luma_minus8: u8,
    bit_depth_chroma_minus8: u8,
    log2_max_transform_skip_block_size_minus2: u8,
    log2_sao_offset_scale_luma: u8,
    log2_sao_offset_scale_chroma: u8,
    high_precision_offsets_enabled_flag: u8,
    _reserved1: [10]u8,
    dependent_slice_segments_enabled_flag: u8,
    slice_segment_header_extension_present_flag: u8,
    sign_data_hiding_enabled_flag: u8,
    cu_qp_delta_enabled_flag: u8,
    diff_cu_qp_delta_depth: u8,
    init_qp_minus26: i8,
    pps_cb_qp_offset: i8,
    pps_cr_qp_offset: i8,
    constrained_intra_pred_flag: u8,
    weighted_pred_flag: u8,
    weighted_bipred_flag: u8,
    transform_skip_enabled_flag: u8,
    transquant_bypass_enabled_flag: u8,
    entropy_coding_sync_enabled_flag: u8,
    log2_parallel_merge_level_minus2: u8,
    num_extra_slice_header_bits: u8,
    loop_filter_across_tiles_enabled_flag: u8,
    loop_filter_across_slices_enabled_flag: u8,
    output_flag_present_flag: u8,
    num_ref_idx_l0_default_active_minus1: u8,
    num_ref_idx_l1_default_active_minus1: u8,
    lists_modification_present_flag: u8,
    cabac_init_present_flag: u8,
    pps_deblocking_filter_disabled_flag: u8,
    pps_beta_offset_div2: i8,
    pps_tc_offset_div2: i8,
    tiles_enabled_flag: u8,
    uniform_spacing_flag: u8,
    num_tile_columns_minus1: u8,
    num_tile_rows_minus1: u8,
    column_width_minus1: [21]c_ushort,
    row_height_minus1: [21]c_ushort,
    sps_range_extension_flag: u8,
    transform_skip_rotation_enabled_flag: u8,
    transform_skip_context_enabled_flag: u8,
    implicit_rdpcm_enabled_flag: u8,
    explicit_rdpcm_enabled_flag: u8,
    extended_precision_processing_flag: u8,
    intra_smoothing_disabled_flag: u8,
    persistent_rice_adaptation_enabled_flag: u8,
    cabac_bypass_alignment_enabled_flag: u8,
    pps_range_extension_flag: u8,
    cross_component_prediction_enabled_flag: u8,
    chroma_qp_offset_list_enabled_flag: u8,
    diff_cu_chroma_qp_offset_depth: u8,
    chroma_qp_offset_list_len_minus1: u8,
    cb_qp_offset_list: [6]i8,
    cr_qp_offset_list: [6]i8,
    _reserved2: [2]u8,
    _reserved3: [8]c_uint,
    NumBitsForShortTermRPSInSlice: c_int,
    NumDeltaPocsOfRefRpsIdx: c_int,
    NumPocTotalCurr: c_int,
    NumPocStCurrBefore: c_int,
    NumPocStCurrAfter: c_int,
    NumPocLtCurr: c_int,
    CurrPicOrderCntVal: c_int,
    RefPicIdx: [16]c_int,
    PicOrderCntVal: [16]c_int,
    IsLongTerm: [16]u8,
    RefPicSetStCurrBefore: [8]u8,
    RefPicSetStCurrAfter: [8]u8,
    RefPicSetLtCurr: [8]u8,
    RefPicSetInterLayer0: [8]u8,
    RefPicSetInterLayer1: [8]u8,
    _reserved4: [12]c_uint,
    ScalingList4x4: [6][16]u8,
    ScalingList8x8: [6][64]u8,
    ScalingList16x16: [6][64]u8,
    ScalingList32x32: [2][64]u8,
    ScalingListDCCoeff16x16: [6]u8,
    ScalingListDCCoeff32x32: [2]u8,
};

pub const JPEGPicParams = extern struct {
    _Reserved: c_int,
};

pub const MPEG2PicParams = extern struct {
    ForwardRefIdx: c_int,
    BackwardRefIdx: c_int,
    picture_coding_type: c_int,
    full_pel_forward_vector: c_int,
    full_pel_backward_vector: c_int,
    f_code: [2][2]c_int,
    intra_dc_precision: c_int,
    frame_pred_frame_dct: c_int,
    concealment_motion_vectors: c_int,
    q_scale_type: c_int,
    intra_vlc_format: c_int,
    alternate_scan: c_int,
    top_field_first: c_int,
    QuantMatrixIntra: [64]u8,
    QuantMatrixInter: [64]u8,
};

pub const MPEG4PicParams = extern struct {
    ForwardRefIdx: c_int,
    BackwardRefIdx: c_int,
    video_object_layer_width: c_int,
    video_object_layer_height: c_int,
    vop_time_increment_bitcount: c_int,
    top_field_first: c_int,
    resync_marker_disable: c_int,
    quant_type: c_int,
    quarter_sample: c_int,
    short_video_header: c_int,
    divx_flags: c_int,
    vop_coding_type: c_int,
    vop_coded: c_int,
    vop_rounding_type: c_int,
    alternate_vertical_scan_flag: c_int,
    interlaced: c_int,
    vop_fcode_forward: c_int,
    vop_fcode_backward: c_int,
    trd: [2]c_int,
    trb: [2]c_int,
    QuantMatrixIntra: [64]u8,
    QuantMatrixInter: [64]u8,
    gmc_enabled: c_int,
};

pub const VC1PicParams = extern struct {
    ForwardRefIdx: c_int,
    BackwardRefIdx: c_int,
    FrameWidth: c_int,
    FrameHeight: c_int,
    intra_pic_flag: c_int,
    ref_pic_flag: c_int,
    progressive_fcm: c_int,
    profile: c_int,
    postprocflag: c_int,
    pulldown: c_int,
    interlace: c_int,
    tfcntrflag: c_int,
    finterpflag: c_int,
    psf: c_int,
    multires: c_int,
    syncmarker: c_int,
    rangered: c_int,
    maxbframes: c_int,
    panscan_flag: c_int,
    refdist_flag: c_int,
    extended_mv: c_int,
    dquant: c_int,
    vstransform: c_int,
    loopfilter: c_int,
    fastuvmc: c_int,
    overlap: c_int,
    quantizer: c_int,
    extended_dmv: c_int,
    range_mapy_flag: c_int,
    range_mapy: c_int,
    range_mapuv_flag: c_int,
    range_mapuv: c_int,
    rangeredfrm: c_int,
};

pub const VP8PicParams = extern struct {
    width: c_int,
    height: c_int,
    first_partition_size: c_uint,
    LastRefIdx: u8,
    GoldenRefIdx: u8,
    AltRefIdx: u8,
    wFrameTagFlags: u8,
    _Reserved1: [4]u8,
    _Reserved2: [3]c_uint,
};

pub const VP9PicParams = extern struct {
    width: c_uint,
    height: c_uint,
    LastRefIdx: u8,
    GoldenRefIdx: u8,
    AltRefIdx: u8,
    colorSpace: u8,
    bitFlags1: c_ushort,
    reserved16Bits: c_ushort,
    refFrameSignBias: [4]u8,
    bitDepthMinus8Luma: u8,
    bitDepthMinus8Chroma: u8,
    loopFilterLevel: u8,
    loopFilterSharpness: u8,
    modeRefLfEnabled: u8,
    log2_tile_columns: u8,
    log2_tile_rows: u8,
    bitFlags2: u8,
    segmentFeatureEnable: [8][4]u8,
    segmentFeatureData: [8][4]c_short,
    mb_segment_tree_probs: [7]u8,
    segment_pred_probs: [3]u8,
    reservedSegment16Bits: [2]u8,
    qpYAc: c_int,
    qpYDc: c_int,
    qpChDc: c_int,
    qpChAc: c_int,
    activeRefIdx: [3]c_uint,
    resetFrameContext: c_uint,
    mcomp_filter_type: c_uint,
    mbRefLfDelta: [4]c_uint,
    mbModeLfDelta: [2]c_uint,
    frameTagSize: c_uint,
    offsetToDctParts: c_uint,
    reserved128Bits: [4]c_uint,
};

pub const ProcParams = extern struct {
    progressive_frame: c_int,
    second_field: c_int,
    top_field_first: c_int,
    unpaired_field: c_int,
    reserved_flags: c_uint,
    reserved_zero: c_uint,
    raw_input_dptr: u64,
    raw_input_pitch: c_uint,
    raw_input_format: c_uint,
    raw_output_dptr: u64,
    raw_output_pitch: c_uint,
    _Reserved1: c_uint,
    output_stream: cuda_bindings.Stream,
    _Reserved: [46]c_uint,
    _Reserved2: [2]?*anyopaque,
};

pub const SourceDataPacket = extern struct {
    flags: c_ulong,
    payload_size: c_ulong,
    payload: [*c]const u8,
    timestamp: VideoTimestamp,
};

pub const VideoFormat = extern struct {
    codec: VideoCodec,
    frame_rate: extern struct {
        numerator: c_uint,
        denominator: c_uint,
    },
    progressive_sequence: u8,
    bit_depth_luma_minus8: u8,
    bit_depth_chroma_minus8: u8,
    min_num_decode_surfaces: u8,
    coded_width: c_uint,
    coded_height: c_uint,
    display_area: extern struct {
        left: c_int,
        top: c_int,
        right: c_int,
        bottom: c_int,
    },
    chroma_format: VideoChromaFormat,
    bitrate: c_uint,
    display_aspect_ratio: extern struct {
        x: c_int,
        y: c_int,
    },
    video_signal_description: extern struct {
        bit_flags_1: u8,
        color_primaries: u8,
        transfer_characteristics: u8,
        matrix_coefficients: u8,
    },
    seqhdr_data_length: c_uint,
};

pub const VideoFormatEx = extern struct {
    format: VideoFormat,
    raw_seqhdr_data: [1024]u8,
};

pub var cuvidGetDecoderCaps: ?*const fn (pdc: ?*DecodeCaps) Result = null;
pub var cuvidCreateDecoder: ?*const fn (phDecoder: ?*VideoDecoder, pdci: ?*CreateInfo) Result = null;
pub var cuvidDestroyDecoder: ?*const fn (hDecoder: VideoDecoder) Result = null;
pub var cuvidDecodePicture: ?*const fn (hDecoder: VideoDecoder, pPicParams: ?*PicParams) Result = null;
pub var cuvidGetDecodeStatus: ?*const fn (hDecoder: VideoDecoder, nPicIdx: c_int, pDecodeStatus: ?*GetDecodeStatus) Result = null;
pub var cuvidMapVideoFrame64: ?*const fn (hDecoder: VideoDecoder, nPicIdx: c_int, pDevPtr: [*c]u64, pPitch: [*c]c_uint, pVPP: ?*ProcParams) Result = null;
pub var cuvidUnmapVideoFrame64: ?*const fn (hDecoder: VideoDecoder, DevPtr: u64) Result = null;
pub var cuvidCtxLockCreate: ?*const fn (pLock: ?*VideoCtxLock, ctx: cuda_bindings.Context) Result = null;
pub var cuvidCtxLockDestroy: ?*const fn (lck: VideoCtxLock) Result = null;
pub var cuvidCtxLock: ?*const fn (lck: VideoCtxLock, reserved_flags: c_uint) Result = null;
pub var cuvidCtxUnlock: ?*const fn (lck: VideoCtxLock, reserved_flags: c_uint) Result = null;
pub var cuvidCreateVideoParser: ?*const fn (pObj: ?*VideoParser, pParams: ?*ParserParams) Result = null;
pub var cuvidParseVideoData: ?*const fn (obj: VideoParser, pPacket: ?*SourceDataPacket) Result = null;
pub var cuvidDestroyVideoParser: ?*const fn (obj: VideoParser) Result = null;

/// You MUST call this function as soon as possible and before starting any threads since it is not thread safe.
pub fn load() !void {
    const std = @import("std");
    const builtin = @import("builtin");

    var nvcuvid = try switch (builtin.target.os.tag) {
        .linux, .macos => std.DynLib.open("libnvcuvid.so.1"),
        .windows => std.DynLib.open("nvcuvid.dll"),
        else => @panic("unsupported operating system"),
    };
    cuvidGetDecoderCaps = nvcuvid.lookup(*const fn (pdc: ?*DecodeCaps) Result, "cuvidGetDecoderCaps") orelse @panic("cuvid library invalid");
    cuvidCreateDecoder = nvcuvid.lookup(*const fn (phDecoder: ?*VideoDecoder, pdci: ?*CreateInfo) Result, "cuvidCreateDecoder") orelse @panic("cuvid library invalid");
    cuvidDestroyDecoder = nvcuvid.lookup(*const fn (hDecoder: VideoDecoder) Result, "cuvidDestroyDecoder") orelse @panic("cuvid library invalid");
    cuvidDecodePicture = nvcuvid.lookup(*const fn (hDecoder: VideoDecoder, pPicParams: ?*PicParams) Result, "cuvidDecodePicture") orelse @panic("cuvid library invalid");
    cuvidGetDecodeStatus = nvcuvid.lookup(*const fn (hDecoder: VideoDecoder, nPicIdx: c_int, pDecodeStatus: ?*GetDecodeStatus) Result, "cuvidGetDecodeStatus") orelse @panic("cuvid library invalid");
    cuvidMapVideoFrame64 = nvcuvid.lookup(*const fn (hDecoder: VideoDecoder, nPicIdx: c_int, pDevPtr: [*c]u64, pPitch: [*c]c_uint, pVPP: ?*ProcParams) Result, "cuvidMapVideoFrame64") orelse @panic("cuvid library invalid");
    cuvidUnmapVideoFrame64 = nvcuvid.lookup(*const fn (hDecoder: VideoDecoder, DevPtr: u64) Result, "cuvidUnmapVideoFrame64") orelse @panic("cuvid library invalid");
    cuvidCtxLockCreate = nvcuvid.lookup(*const fn (pLock: [*c]VideoCtxLock, ctx: cuda_bindings.Context) Result, "cuvidCtxLockCreate") orelse @panic("cuvid library invalid");
    cuvidCtxLockDestroy = nvcuvid.lookup(*const fn (lck: VideoCtxLock) Result, "cuvidCtxLockDestroy") orelse @panic("cuvid library invalid");
    cuvidCtxLock = nvcuvid.lookup(*const fn (lck: VideoCtxLock, reserved_flags: c_uint) Result, "cuvidCtxLock") orelse @panic("cuvid library invalid");
    cuvidCtxUnlock = nvcuvid.lookup(*const fn (lck: VideoCtxLock, reserved_flags: c_uint) Result, "cuvidCtxUnlock") orelse @panic("cuvid library invalid");
    cuvidCreateVideoParser = nvcuvid.lookup(*const fn (pObj: ?*VideoParser, pParams: ?*ParserParams) Result, "cuvidCreateVideoParser") orelse @panic("cuvid library invalid");
    cuvidParseVideoData = nvcuvid.lookup(*const fn (obj: VideoParser, pPacket: ?*SourceDataPacket) Result, "cuvidParseVideoData") orelse @panic("cuvid library invalid");
    cuvidDestroyVideoParser = nvcuvid.lookup(*const fn (obj: VideoParser) Result, "cuvidDestroyVideoParser") orelse @panic("cuvid library invalid");
}
