pub const Cuviddecodecaps = extern struct {
    eCodecType: cudaVideoCodec,
    eChromaFormat: cudaVideoChromaFormat,
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

pub const Cuvidgetdecodestatus = extern struct {
    decodeStatus: cuvidDecodeStatus,
    _reserved: [31]c_uint,
    pReserved: [8]?*anyopaque,
};

pub const Cuvidprocparams = extern struct {
    progressive_frame: c_int,
    second_field: c_int,
    top_field_first: c_int,
    unpaired_field: c_int,
    _reserved_flags: c_uint,
    _reserved_zero: c_uint,
    raw_input_dptr: c_ulonglong,
    raw_input_pitch: c_uint,
    raw_input_format: c_uint,
    raw_output_dptr: c_ulonglong,
    raw_output_pitch: c_uint,
    Reserved1: c_uint,
    output_stream: CUstream,
    Reserved: [46]c_uint,
    Reserved2: [2]?*anyopaque,
};
