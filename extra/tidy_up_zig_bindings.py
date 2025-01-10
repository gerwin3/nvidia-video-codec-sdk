out = []

def run(input_file):
    with open(input_file) as f:
        lines = f.readlines()
        lines = [l.strip() for l in lines if l.strip() != '']
    for line in lines:
        try_rewrite_nvenc_enum(line, lines)

def try_rewrite_nvenc_enum(line, lines):
    """
    Rewrites:

    ```zig
    pub const NV_ENC_STEREO_PACKING_MODE_NONE: c_int = 0;
    pub const NV_ENC_STEREO_PACKING_MODE_CHECKERBOARD: c_int = 1;
    pub const NV_ENC_STEREO_PACKING_MODE_COLINTERLEAVE: c_int = 2;
    pub const NV_ENC_STEREO_PACKING_MODE_ROWINTERLEAVE: c_int = 3;
    pub const NV_ENC_STEREO_PACKING_MODE_SIDEBYSIDE: c_int = 4;
    pub const NV_ENC_STEREO_PACKING_MODE_TOPBOTTOM: c_int = 5;
    pub const NV_ENC_STEREO_PACKING_MODE_FRAMESEQ: c_int = 6;
    pub const enum__NV_ENC_STEREO_PACKING_MODE = c_uint;
    pub const NV_ENC_STEREO_PACKING_MODE = enum__NV_ENC_STEREO_PACKING_MODE;
    ```

    To:

    ```zig
    pub const NvEncStereoPackingMode = enum(c_uint) {
        .none = 0,
        .checkerboard = 1,
        .colinterleave = 2,
        .rowinterleave = 3,
        .sidebyside = 4,
        .topbottom = 5,
        .framesq = 6,
    };
    ```
    """
    parts = line.split(' ')
    if len(parts) >= 2 and parts[-2] == '=' and parts[-1].startswith('enum__'):
        orig_name = parts[2]
        new_name = orig_name.replace('NVENC', 'NV_ENC_')
        new_name = pascalize(new_name)
        value_lines = [l for l in lines if l.startswith(f'pub const {orig_name}') and ': c_int = ' in l]
        data_type = [l for l in lines if f'pub const enum__{orig_name}' in l][0].split(' ')[-1][0:-1]
        obj = [f'pub const {new_name} = enum({data_type}) {{']
        for value_line in value_lines:
            tag = value_line.split(' ')[2][0:-1].replace(f'{orig_name}_', '')
            tag = snakize(tag)
            value = int(value_line.split(' ')[-1][0:-1])
            obj += [f'    .{tag} = {value},']
        obj += ['};']
        print('\n'.join(obj))

def pascalize(s):
    out = ''
    nextcap = True
    for c in s:
        if c == '_':
            nextcap = True
        elif nextcap:
            out += c.upper()
            nextcap = False
        else:
            out += c.lower()
    out = out.replace('MvPrecision', 'MVPrecision')
    out = out.replace('FmoMode', 'FMOMode')
    out = out.replace('Hevc', 'HEVC')
    out = out.replace('Bframe', 'BFrame')
    out = out.replace('Bdirect', 'BDirect')
    out = out.replace('QpMap', 'QPMap')
    return out

def snakize(s):
    return s.lower()

if __name__ == "__main__":
    import sys
    run(sys.argv[1])
