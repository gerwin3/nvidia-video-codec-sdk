import os
out = []

def run(input_file):
    global out
    with open(input_file) as f:
        lines = f.readlines()
        lines = [l.strip() for l in lines]
    for line_index, line in enumerate(lines):
        # try_rewrite_nvenc_enum(line_index, line, lines)
        try_rewrite_struct(line_index, line, lines)
    out = list(sorted(out, key=lambda obj: obj[0]))
    for obj in out:
        print('\n'.join(obj))
        print()

def try_rewrite_struct(line_index, line, lines):
    """
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
    """
    global out
    parts = line.split(' ')
    if len(parts) >= 3 and parts[0] == 'pub' and parts[1] == 'const' and parts[2].startswith('struct__'):
        orig_name = parts[2]
        new_name = orig_name.replace('struct__', '')
        new_name = new_name.replace('NVENC', 'NV_ENC_')
        new_name = pascalize(new_name)
        new_name = new_name.replace('NvEnc', '')
        obj = [f'pub const {new_name} = extern struct {{']
        while True:
            line_index += 1
            if lines[line_index].strip() == '};':
                break
            line = lines[line_index]
            parts = line.split('=')
            assert(len(parts) == 2)
            out_line = parts[0].strip()
            if out_line.startswith('reserved'):
                out_line = f'_{out_line}'
            out_line = f'    {out_line},'
            obj += [out_line]
        obj += ['};']
        out.append(obj)


def try_rewrite_nvenc_enum(line_index, line, lines):
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
    global out
    parts = line.split(' ')
    if len(parts) >= 2 and parts[-2] == '=' and parts[-1].startswith('enum__'):
        orig_name = parts[2]
        new_name = orig_name.replace('NVENC', 'NV_ENC_')
        new_name = pascalize(new_name)
        new_name = new_name.replace('NvEnc', '')
        data_type = [l for l in lines if f'pub const enum__{orig_name}' in l][0].split(' ')[-1][0:-1]
        obj = [f'pub const {new_name} = enum({data_type}) {{']

        vl_start = line_index - 2
        value_lines = []
        while True:
            if lines[vl_start].strip() == '':
                break
            vl_start -= 1
        for i in range(vl_start + 1, line_index - 1):
            value_lines.append(lines[i])
        # value_lines = [l for l in lines if l.startswith(f'pub const {orig_name}') and ': c_int = ' in l]
        tagvs = []
        for value_line in value_lines:
            tag = value_line.split(' ')[2][0:-1].replace(f'{orig_name}_', '')
            tag = snakize(tag)
            value = int(value_line.split(' ')[-1][0:-1])
            tagvs.append((tag, value))
        commontag = os.path.commonprefix([t for (t, _) in tagvs])
        for tag, value in tagvs:
            tag = tag[len(commontag):]
            if tag.startswith('err_'):
                tag = tag[4:]
            tag = tag.replace('nv_enc_tier_', '')
            if tag[0].isnumeric():
                tag = f'@"{tag}"'
            obj += [f'    {tag} = {value},']
        obj += ['};']
        out.append(obj)

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
