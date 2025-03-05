const std = @import("std");

const cuda = @import("cuda");
const nvenc = @import("nvenc");
const nvdec = @import("nvdec");

const long_duration = 256;
const short_duration = 64;

test "default h264 full hd" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        long_duration,
    );
}

test "default h264 4k" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 3840, .height = 2160 },
        },
        short_duration,
    );
}

test "h264 full hd yuv444" {
    // Unfortunately we can only test the encoder here since NVDEC does not
    // support YUV444.
    // The encoder test is a sanity check only.
    try test_encoder_only(
        .yuv444,
        .{
            .codec = .{ .h264 = .{ .format = .yuv444 } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "h264 full hd profile main" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{ .profile = .main } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "h264 full hd profile high" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{ .profile = .high } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "h264 full hd 60fps" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .frame_rate = .{ .num = 60, .den = 1 },
        },
        short_duration,
    );
}

fn test_h264_full_hd_preset(preset: nvenc.Preset) !void {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .preset = preset,
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "h264 full hd p1" {
    try test_h264_full_hd_preset(.p1);
}

test "h264 full hd p2" {
    try test_h264_full_hd_preset(.p2);
}

test "h264 full hd p3" {
    try test_h264_full_hd_preset(.p3);
}

test "h264 full hd p4" {
    try test_h264_full_hd_preset(.p4);
}

test "h264 full hd p5" {
    try test_h264_full_hd_preset(.p5);
}

// TODO: This one give invalid param.
// test "h264 full hd p6" {
//     try test_h264_full_hd_preset(.p6);
// }

// TODO: This one give invalid param.
// test "h264 full hd p7" {
//     try test_h264_full_hd_preset(.p7);
// }

test "h264 full hd p1 tuning" {
    inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
        try test_encoder_decoder(
            .nv12,
            .{
                .codec = .{ .h264 = .{} },
                .preset = .p1,
                .tuning = @field(nvenc.Tuning, tuning.name),
                .resolution = .{ .width = 1920, .height = 1080 },
            },
            short_duration,
        );
    }
}

// TODO:

// test "h264 full hd p7 tuning" {
//     inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
//         try test_encoder_decoder(
//             .{
//                 .codec = .{ .h264 = .{} },
//                 .preset = .p7,
//                 .tuning = @field(nvenc.Tuning, tuning.name),
//                 .resolution = .{ .width = 1920, .height = 1080 },
//             },
//             short_duration,
//         );
//     }
// }

test "h264 full hd idr interval 2" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .idr_interval = 2,
        },
        short_duration,
    );
}

test "h264 full hd rate control cbr" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .cbr = .{ .bitrate = 2_000_000 } },
        },
        short_duration,
    );
}

test "h264 full hd rate control vbr" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .vbr = .{
                .average_bitrate = 2_000_000,
                .max_bitrate = 10_000_000,
            } },
        },
        short_duration,
    );
}

test "h264 full hd rate const qp" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .const_qp = .{
                .inter_p = 20,
                .inter_b = 20,
                .intra = 20,
            } },
        },
        short_duration,
    );
}

test "default hevc full hd" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "default hevc 4k" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 3840, .height = 2160 },
        },
        short_duration,
    );
}

test "hevc full hd yuv444" {
    try test_encoder_decoder(
        .yuv444,
        .{
            .codec = .{ .hevc = .{ .format = .yuv444 } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "hevc full hd profile main" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{ .profile = .main } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "hevc full hd profile main10" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{ .profile = .main10 } },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "hevc full hd 60fps" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .frame_rate = .{ .num = 60, .den = 1 },
        },
        short_duration,
    );
}

fn test_hevc_full_hd_preset(preset: nvenc.Preset) !void {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .preset = preset,
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        short_duration,
    );
}

test "hevc full hd p1" {
    try test_hevc_full_hd_preset(.p1);
}

test "hevc full hd p2" {
    try test_hevc_full_hd_preset(.p2);
}

test "hevc full hd p3" {
    try test_hevc_full_hd_preset(.p3);
}

test "hevc full hd p4" {
    try test_hevc_full_hd_preset(.p4);
}

test "hevc full hd p5" {
    try test_hevc_full_hd_preset(.p5);
}

test "hevc full hd p6" {
    try test_hevc_full_hd_preset(.p6);
}

test "hevc full hd p7" {
    try test_hevc_full_hd_preset(.p7);
}

test "hevc full hd p1 tuning" {
    inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
        try test_encoder_decoder(
            .nv12,
            .{
                .codec = .{ .hevc = .{} },
                .preset = .p1,
                .tuning = @field(nvenc.Tuning, tuning.name),
                .resolution = .{ .width = 1920, .height = 1080 },
            },
            short_duration,
        );
    }
}

test "hevc full hd p7 tuning" {
    inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
        try test_encoder_decoder(
            .nv12,
            .{
                .codec = .{ .hevc = .{} },
                .preset = .p7,
                .tuning = @field(nvenc.Tuning, tuning.name),
                .resolution = .{ .width = 1920, .height = 1080 },
            },
            short_duration,
        );
    }
}

test "hevc full hd idr interval 2" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .idr_interval = 2,
        },
        short_duration,
    );
}

test "hevc full hd rate control cbr" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .cbr = .{ .bitrate = 2_000_000 } },
        },
        short_duration,
    );
}

test "hevc full hd rate control vbr" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .vbr = .{
                .average_bitrate = 2_000_000,
                .max_bitrate = 10_000_000,
            } },
        },
        short_duration,
    );
}

test "hevc full hd rate const qp" {
    try test_encoder_decoder(
        .nv12,
        .{
            .codec = .{ .hevc = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
            .rate_control = .{ .const_qp = .{
                .inter_p = 20,
                .inter_b = 20,
                .intra = 20,
            } },
        },
        short_duration,
    );
}

// TODO: switch up card with one of Adas then test this

// test "default av1 full hd" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//         },
//         long_duration,
//     );
// }
//
// test "default av1 4k" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 3840, .height = 2160 },
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd profile main" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{ .profile = .main } },
//             .resolution = .{ .width = 1920, .height = 1080 },
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd 60fps" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//             .frame_rate = .{ .num = 60, .den = 1 },
//         },
//         short_duration,
//     );
// }
//
// fn test_av1_full_hd_preset(preset: nvenc.Preset) !void {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .preset = preset,
//             .resolution = .{ .width = 1920, .height = 1080 },
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd p1" {
//     try test_av1_full_hd_preset(.p1);
// }
//
// test "av1 full hd p2" {
//     try test_av1_full_hd_preset(.p2);
// }
//
// test "av1 full hd p3" {
//     try test_av1_full_hd_preset(.p3);
// }
//
// test "av1 full hd p4" {
//     try test_av1_full_hd_preset(.p4);
// }
//
// test "av1 full hd p5" {
//     try test_av1_full_hd_preset(.p5);
// }
//
// test "av1 full hd p6" {
//     try test_av1_full_hd_preset(.p6);
// }
//
// test "av1 full hd p7" {
//     try test_av1_full_hd_preset(.p7);
// }
//
// test "av1 full hd p1 tuning" {
//     inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
//         try test_encoder_decoder(
//             .nv12,
//             .{
//                 .codec = .{ .av1 = .{} },
//                 .preset = .p1,
//                 .tuning = @field(nvenc.Tuning, tuning.name),
//                 .resolution = .{ .width = 1920, .height = 1080 },
//             },
//             short_duration,
//         );
//     }
// }
//
// test "av1 full hd p7 tuning" {
//     inline for (std.meta.fields(nvenc.Tuning)) |tuning| {
//         try test_encoder_decoder(
//             .nv12,
//             .{
//                 .codec = .{ .av1 = .{} },
//                 .preset = .p7,
//                 .tuning = @field(nvenc.Tuning, tuning.name),
//                 .resolution = .{ .width = 1920, .height = 1080 },
//             },
//             short_duration,
//         );
//     }
// }
//
// test "av1 full hd idr interval 2" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//             .idr_interval = 2,
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd rate control cbr" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//             .rate_control = .{ .cbr = .{ .bitrate = 2_000_000 } },
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd rate control vbr" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//             .rate_control = .{ .vbr = .{
//                 .average_bitrate = 2_000_000,
//                 .max_bitrate = 10_000_000,
//             } },
//         },
//         short_duration,
//     );
// }
//
// test "av1 full hd rate const qp" {
//     try test_encoder_decoder(
//         .nv12,
//         .{
//             .codec = .{ .av1 = .{} },
//             .resolution = .{ .width = 1920, .height = 1080 },
//             .rate_control = .{ .const_qp = .{
//                 .inter_p = 20,
//                 .inter_b = 20,
//                 .intra = 20,
//             } },
//         },
//         short_duration,
//     );
// }

const TestColor = enum {
    red,
    green,
    blue,
    pink,

    fn to_yuv(self: TestColor) [3]f32 {
        return switch (self) {
            .red => rgb2yuv(.{ 255.0, 0.0, 0.0 }),
            .green => rgb2yuv(.{ 0.0, 255.0, 0.0 }),
            .blue => rgb2yuv(.{ 0.0, 0.0, 255.0 }),
            .pink => rgb2yuv(.{ 255.0, 0.0, 255.0 }),
        };
    }

    fn from_yuv(yuv: [3]f32) ?TestColor {
        const epsilon = 5.0;
        const rgb = yuv2rgb(yuv);
        if ((255.0 - rgb[0] < epsilon) and rgb[1] < epsilon and rgb[2] < epsilon)
            return .red
        else if (rgb[0] < epsilon and (255.0 - rgb[1] < epsilon) and rgb[2] < epsilon)
            return .green
        else if (rgb[0] < epsilon and rgb[1] < epsilon and (255.0 - rgb[2] < epsilon))
            return .blue
        else if ((255.0 - rgb[0] < epsilon) and rgb[1] < epsilon and (255.0 - rgb[2] < epsilon))
            return .pink
        else
            return null;
    }
};

const TestFrame = struct {
    /// Top left
    q1: TestColor,
    /// Top right
    q2: TestColor,
    /// Bottom left
    q3: TestColor,
    /// Bottom right
    q4: TestColor,

    fn from_rotation_no(index: usize) TestFrame {
        return switch (index % 4) {
            0 => .{ .q1 = .red, .q2 = .green, .q3 = .blue, .q4 = .pink },
            1 => .{ .q1 = .green, .q2 = .blue, .q3 = .pink, .q4 = .red },
            2 => .{ .q1 = .blue, .q2 = .pink, .q3 = .red, .q4 = .green },
            3 => .{ .q1 = .pink, .q2 = .red, .q3 = .green, .q4 = .blue },
            else => unreachable,
        };
    }

    fn copy_to_buffer_nv12(
        self: *const TestFrame,
        buffer: []u8,
        dims: struct { width: u32, height: u32 },
    ) void {
        const y_plane = buffer[0 .. dims.height * dims.width];
        const uv_plane = buffer[dims.height * dims.width ..];
        for (0..dims.height) |y| {
            for (0..dims.width) |x| {
                const top = y <= (dims.height / 2);
                const left = x <= (dims.width / 2);
                const color = if (top and left) self.q1 else if (top and !left) self.q2 else if (!top and left) self.q3 else if (!top and !left) self.q4 else unreachable;
                const yuv = color_bytes(color.to_yuv());
                y_plane[(dims.width * y) + x] = yuv[0];
                if (x % 2 == 0 and y % 2 == 0) {
                    uv_plane[(dims.width * (y / 2)) + x] = yuv[1];
                    uv_plane[(dims.width * (y / 2)) + x + 1] = yuv[2];
                }
            }
        }
    }

    fn copy_to_buffer_yuv444(
        self: *const TestFrame,
        buffer: []u8,
        dims: struct { width: u32, height: u32 },
    ) void {
        const y_plane = buffer[0 .. dims.height * dims.width];
        const u_plane = buffer[dims.height * dims.width .. 2 * dims.height * dims.width];
        const v_plane = buffer[2 * dims.height * dims.width ..];
        for (0..dims.height) |y| {
            for (0..dims.width) |x| {
                const top = y <= (dims.height / 2);
                const left = x <= (dims.width / 2);
                const color = if (top and left) self.q1 else if (top and !left) self.q2 else if (!top and left) self.q3 else if (!top and !left) self.q4 else unreachable;
                const yuv = color_bytes(color.to_yuv());
                y_plane[(dims.width * y) + x] = yuv[0];
                u_plane[(dims.width * y) + x] = yuv[1];
                v_plane[(dims.width * y) + x] = yuv[2];
            }
        }
    }

    fn expect_similar(
        self: *const TestFrame,
        frame: struct {
            data: struct { luma: []u8, chroma: []u8 },
            dims: struct { width: u32, height: u32 },
        },
    ) !void {
        // You will just have to believe me that this function tests whether
        // the decoded frame is the same frame as the original test frame
        // during encoding.
        const w = frame.dims.width;
        const h = frame.dims.height;
        const h2 = frame.dims.height / 2;
        const q1 = .{
            frame.data.luma[((h / 4) * w) + (w / 4)],
            frame.data.chroma[((h2 / 4) * w) + (w / 4)],
            frame.data.chroma[((h2 / 4) * w) + (w / 4) + 1],
        };
        const q2 = .{
            frame.data.luma[((h / 4) * w) + (w / 4 * 3)],
            frame.data.chroma[((h2 / 4) * w) + (w / 4 * 3)],
            frame.data.chroma[((h2 / 4) * w) + (w / 4 * 3) + 1],
        };
        const q3 = .{
            frame.data.luma[((h / 4 * 3) * w) + (w / 4)],
            frame.data.chroma[((h2 / 4 * 3) * w) + (w / 4)],
            frame.data.chroma[((h2 / 4 * 3) * w) + (w / 4) + 1],
        };
        const q4 = .{
            frame.data.luma[((h / 4 * 3) * w) + (w / 4 * 3)],
            frame.data.chroma[((h2 / 4 * 3) * w) + (w / 4 * 3)],
            frame.data.chroma[((h2 / 4 * 3) * w) + (w / 4 * 3) + 1],
        };
        const got_test_frame = TestFrame{
            .q1 = TestColor.from_yuv(color_f32(q1)) orelse return error.TestUnmatchedColor,
            .q2 = TestColor.from_yuv(color_f32(q2)) orelse return error.TestUnmatchedColor,
            .q3 = TestColor.from_yuv(color_f32(q3)) orelse return error.TestUnmatchedColor,
            .q4 = TestColor.from_yuv(color_f32(q4)) orelse return error.TestUnmatchedColor,
        };
        try std.testing.expectEqualDeep(self.*, got_test_frame);
    }
};

const TestFrameIterator = struct {
    const rotate_every: usize = 12;

    index: usize = 0,
    max: usize,

    fn init(max: usize) TestFrameIterator {
        return .{ .max = max };
    }

    fn reset(self: *TestFrameIterator) void {
        self.index = 0;
    }

    fn next(self: *TestFrameIterator) ?TestFrame {
        if (self.index >= self.max) return null;
        const rotation = self.index / rotate_every;
        self.index += 1;
        return TestFrame.from_rotation_no(rotation);
    }
};

const FrameBuffer = struct {
    luma: []u8,
    chroma: []u8,
    allocator: std.mem.Allocator,

    fn alloc(width: u32, height: u32, allocator: std.mem.Allocator) !FrameBuffer {
        const luma = try allocator.alloc(u8, height * width);
        errdefer allocator.free(luma);
        const chroma = try allocator.alloc(u8, height / 2 * width);
        errdefer allocator.free(chroma);
        return FrameBuffer{
            .luma = luma,
            .chroma = chroma,
            .allocator = allocator,
        };
    }

    fn free(self: *const FrameBuffer) void {
        self.allocator.free(self.luma);
        self.allocator.free(self.chroma);
    }
};

const TestSupportedInputFrameFormat = enum { nv12, yuv444 };

fn test_encoder_decoder(
    comptime in_frame_format: TestSupportedInputFrameFormat,
    encoder_options: nvenc.EncoderOptions,
    num_frames: usize,
) !void {
    return test_impl(.encode_decode, in_frame_format, encoder_options, num_frames);
}

fn test_encoder_only(
    comptime in_frame_format: TestSupportedInputFrameFormat,
    encoder_options: nvenc.EncoderOptions,
    num_frames: usize,
) !void {
    return test_impl(.encode_only_sanity_check, in_frame_format, encoder_options, num_frames);
}

fn test_impl(
    comptime mode: enum { encode_decode, encode_only_sanity_check },
    comptime in_frame_format: TestSupportedInputFrameFormat,
    encoder_options: nvenc.EncoderOptions,
    num_frames: usize,
) !void {
    const allocator = std.testing.allocator;

    try init();

    var context = try cuda.Context.init(0);
    defer context.deinit();

    var encoder = try nvenc.Encoder.init(&context, encoder_options, allocator);
    defer encoder.deinit();

    const width = encoder_options.resolution.width;
    const height = encoder_options.resolution.height;
    std.debug.assert(width % 2 == 0);
    std.debug.assert(height % 2 == 0);
    const data_height = switch (in_frame_format) {
        .nv12 => height * 3 / 2,
        .yuv444 => height * 3,
    };

    const in_frame_data_host = try allocator.alloc(u8, data_height * width);
    defer allocator.free(in_frame_data_host);

    try context.push();
    const in_frame_data_device = try nvenc.cuda.allocPitch(width, data_height, .element_size_16);
    defer {
        context.push() catch unreachable;
        nvenc.cuda.free(in_frame_data_device.ptr);
        context.pop() catch unreachable;
    }
    try context.pop();

    var in_frame = nvenc.Frame{
        .data = in_frame_data_device.ptr,
        .format = switch (in_frame_format) {
            .nv12 => .nv12,
            .yuv444 => .yuv444,
        },
        .pitch = @intCast(in_frame_data_device.pitch),
        .dims = .{
            .width = width,
            .height = height,
        },
        .timestamp = 0,
    };

    var bitstream = std.ArrayList(u8).init(allocator);
    defer bitstream.deinit();
    const bitstream_writer = bitstream.writer();

    var test_frames = TestFrameIterator.init(num_frames);
    while (test_frames.next()) |test_frame| {
        switch (in_frame_format) {
            .nv12 => test_frame.copy_to_buffer_nv12(in_frame_data_host, .{ .width = width, .height = height }),
            .yuv444 => test_frame.copy_to_buffer_yuv444(in_frame_data_host, .{ .width = width, .height = height }),
        }
        try context.push();
        try nvenc.cuda.copy2D(
            .{
                .host_to_device = .{
                    .src = in_frame_data_host,
                    .dst = in_frame.data,
                },
            },
            .{
                .src_pitch = width,
                .dst_pitch = in_frame.pitch,
                .dims = .{
                    .width = width,
                    .height = data_height,
                },
            },
        );
        try context.pop();
        try encoder.encode(&in_frame, bitstream_writer);
    }

    try encoder.flush(bitstream_writer);

    test_frames.reset();

    switch (mode) {
        .encode_decode => {
            var out_frame_buffer = try FrameBuffer.alloc(width, height, allocator);
            defer out_frame_buffer.free();

            const bitstream_buffer = bitstream.items;

            const decoder_codec = switch (encoder_options.codec) {
                .h264 => nvdec.Codec.h264,
                .hevc => nvdec.Codec.hevc,
                .av1 => nvdec.Codec.av1,
            };

            var decoder = try nvdec.Decoder.create(&context, .{ .codec = decoder_codec, .output_format = .nv12 }, allocator);
            defer decoder.destroy();

            var last_nal: ?usize = 0;

            const len_range = @max(bitstream_buffer.len, 4) - 4;
            for (0..len_range) |index| {
                if (std.mem.eql(u8, bitstream_buffer[index .. index + 4], &.{ 0, 0, 0, 1 })) {
                    if (last_nal) |last_nal_index| {
                        const nal = bitstream_buffer[last_nal_index..index];
                        if (try decoder.decode(nal)) |out_frame| {
                            try test_expected_frame(decoder.context, &test_frames, &out_frame, &out_frame_buffer);
                        }
                        last_nal = index;
                    } else {
                        last_nal = 0;
                    }
                }
            }

            if (last_nal) |last_nal_index| {
                const nal = bitstream_buffer[last_nal_index..];

                if (try decoder.decode(nal)) |out_frame| {
                    try test_expected_frame(decoder.context, &test_frames, &out_frame, &out_frame_buffer);
                }
            }

            while (try decoder.flush()) |out_frame| {
                try test_expected_frame(decoder.context, &test_frames, &out_frame, &out_frame_buffer);
            }

            try std.testing.expectEqual(test_frames.next(), @as(?TestFrame, null));
        },
        .encode_only_sanity_check => {
            try std.testing.expect(bitstream.items.len > 1024);
        },
    }
}

fn test_expected_frame(
    context: *cuda.Context,
    test_frames_it: *TestFrameIterator,
    out_frame: *const nvdec.Frame,
    out_frame_buffer: *const FrameBuffer,
) !void {
    const expected_test_frame = test_frames_it.next() orelse return error.TestUnexpectedFrame;

    try context.push();
    try out_frame.copy_to_host(.{
        .luma = out_frame_buffer.luma,
        .chroma = out_frame_buffer.chroma,
    });
    try context.pop();

    try expected_test_frame.expect_similar(.{
        .data = .{
            .luma = out_frame_buffer.luma,
            .chroma = out_frame_buffer.chroma,
        },
        .dims = .{
            .width = out_frame.dims.width,
            .height = out_frame.dims.height,
        },
    });
}

fn init() !void {
    const static = struct {
        var is_initialized: bool = false;
    };

    if (!static.is_initialized) {
        try cuda.load();
        try cuda.init();
        try nvenc.load();
        try nvdec.load();
        static.is_initialized = true;
    }
}

fn rgb2yuv(rgb: [3]f32) [3]f32 {
    return .{
        (0.257 * rgb[0]) + (0.504 * rgb[1]) + (0.098 * rgb[2]) + 16.0,
        (-0.148 * rgb[0]) + (-0.291 * rgb[1]) + (0.439 * rgb[2]) + 128.0,
        (0.439 * rgb[0]) + (-0.368 * rgb[1]) + (-0.071 * rgb[2]) + 128.0,
    };
}

fn yuv2rgb(yuv: [3]f32) [3]f32 {
    const y = yuv[0] - 16.0;
    const u = yuv[1] - 128.0;
    const v = yuv[2] - 128.0;
    return .{
        1.164 * y + 1.596 * v,
        1.164 * y - 0.392 * u - 0.813 * v,
        1.164 * y + 2.017 * u,
    };
}

fn color_f32(color: [3]u8) [3]f32 {
    return .{
        @floatFromInt(color[0]),
        @floatFromInt(color[1]),
        @floatFromInt(color[2]),
    };
}

fn color_bytes(color: [3]f32) [3]u8 {
    return .{
        @intFromFloat(color[0]),
        @intFromFloat(color[1]),
        @intFromFloat(color[2]),
    };
}
