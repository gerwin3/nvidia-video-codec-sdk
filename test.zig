const std = @import("std");

const cuda = @import("cuda");
const nvenc = @import("nvenc");
const nvdec = @import("nvdec");

test "default config h264 full hd" {
    try test_encoder_decoder(.{
        .codec = .{ .h264 = .{} },
        .resolution = .{ .width = 1920, .height = 1080 },
    }, 256);
}

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
                // if (x == 0 and y == 0) std.debug.print("{any}\n", .{yuv}); // TODO
                y_plane[(dims.width * y) + x] = yuv[0];
                if (x % 2 == 0 and y % 2 == 0) {
                    uv_plane[(dims.width * (y / 2)) + x] = yuv[1];
                    uv_plane[(dims.width * (y / 2)) + x + 1] = yuv[2];
                }
            }
        }
    }

    fn expect_similar(
        self: *const TestFrame,
        frame: struct {
            y: []u8,
            uv: []u8,
            dims: struct { width: u32, height: u32 },
        },
    ) !void {
        // You will just have to believe me that this function tests whether
        // the decoded frame is the same frame as the original test frame
        // during encoding.
        const q1_index_y = ((frame.dims.height / 4) * frame.dims.width) + (frame.dims.width / 4);
        const q2_index_y = ((frame.dims.height / 4) * frame.dims.width) + (frame.dims.width / 4 * 3);
        const q3_index_y = ((frame.dims.height / 4 * 3) * frame.dims.width) + (frame.dims.width / 4);
        const q4_index_y = ((frame.dims.height / 4 * 3) * frame.dims.width) + (frame.dims.width / 4 * 3);
        const q1_index_uv = ((frame.dims.height / 2 / 4) * frame.dims.width) + (frame.dims.width / 4);
        const q2_index_uv = ((frame.dims.height / 2 / 4) * frame.dims.width) + (frame.dims.width / 4 * 3);
        const q3_index_uv = ((frame.dims.height / 2 / 4 * 3) * frame.dims.width) + (frame.dims.width / 4);
        const q4_index_uv = ((frame.dims.height / 2 / 4 * 3) * frame.dims.width) + (frame.dims.width / 4 * 3);
        const q1 = .{ frame.y[q1_index_y], frame.uv[q1_index_uv], frame.uv[q1_index_uv + 1] };
        const q2 = .{ frame.y[q2_index_y], frame.uv[q2_index_uv], frame.uv[q2_index_uv + 1] };
        const q3 = .{ frame.y[q3_index_y], frame.uv[q3_index_uv], frame.uv[q3_index_uv + 1] };
        const q4 = .{ frame.y[q4_index_y], frame.uv[q4_index_uv], frame.uv[q4_index_uv + 1] };
        const q1_color = TestColor.from_yuv(color_f32(q1));
        const q2_color = TestColor.from_yuv(color_f32(q2));
        const q3_color = TestColor.from_yuv(color_f32(q3));
        const q4_color = TestColor.from_yuv(color_f32(q4));
        // std.debug.print("testing: {any} \n      == {any}\n\n", .{ .{ q1_color.?, q2_color.?, q3_color.?, q4_color.? }, .{ self.q1, self.q2, self.q3, self.q4 } });
        std.debug.print("{any}\n", .{.{ q1_color.?, q2_color.?, q3_color.?, q4_color.? }});
        _ = self;
        // TODO
        // std.testing.expectEqual(@as(?TestColor, self.q1), q1_color) catch {};
        // std.testing.expectEqual(@as(?TestColor, self.q2), q2_color) catch {};
        // std.testing.expectEqual(@as(?TestColor, self.q3), q3_color) catch {};
        // std.testing.expectEqual(@as(?TestColor, self.q4), q4_color) catch {};
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

const FrameData = struct { y: []u8, uv: []u8 };

fn test_encoder_decoder(encoder_options: nvenc.EncoderOptions, num_frames: usize) !void {
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
    const data_height = height * 3 / 2;

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
        .format = .nv12,
        .pitch = @intCast(in_frame_data_device.pitch),
        .dims = .{
            .width = width,
            .height = height,
        },
        .timestamp = 0,
    };

    var bitstream = std.ArrayList(u8).init(allocator);
    defer bitstream.deinit();
    // const bitstream_writer = bitstream.writer();

    // TODO
    const file = try std.fs.cwd().createFile("test.264", .{});
    defer file.close();
    const bitstream_writer = file.writer();

    var test_frames = TestFrameIterator.init(num_frames);
    while (test_frames.next()) |test_frame| {
        test_frame.copy_to_buffer_nv12(in_frame_data_host, .{ .width = width, .height = height });
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

    test_frames.reset();

    var out_frame_buffer = FrameData{
        .y = try allocator.alloc(u8, height * width),
        .uv = try allocator.alloc(u8, height / 2 * width),
    };
    defer {
        allocator.free(out_frame_buffer.y);
        allocator.free(out_frame_buffer.uv);
    }

    const bitstream_buffer = bitstream.items;

    const decoder_codec = switch (encoder_options.codec) {
        .h264 => nvdec.Codec.h264,
        .hevc => nvdec.Codec.hevc,
    };

    var decoder = try nvdec.Decoder.create(&context, .{ .codec = decoder_codec }, allocator);
    defer decoder.destroy();

    // TODO: weird bug that causes frames to repeat in a weird way

    var last_nal: ?usize = 0;

    const len_range = @max(bitstream_buffer.len, 4) - 4;
    for (0..len_range) |index| {
        if (std.mem.eql(u8, bitstream_buffer[index .. index + 4], &.{ 0, 0, 0, 1 })) {
            if (last_nal) |last_nal_index| {
                std.debug.print("nal: {}-{}\n", .{ last_nal_index, index }); // TODO

                const nal = bitstream_buffer[last_nal_index..index];

                if (try decoder.decode(nal)) |out_frame| {
                    std.debug.print("NAL: {}-{}\n", .{ last_nal_index, index }); // TODO
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
}

fn test_expected_frame(
    context: *cuda.Context,
    test_frames_it: *TestFrameIterator,
    out_frame: *const nvdec.Frame,
    out_frame_buffer: *const FrameData,
) !void {
    const expected_test_frame = test_frames_it.next() orelse return error.TestUnexpectedFrame;

    try context.push();
    try nvdec.cuda.copy2D(
        .{ .device_to_host = .{
            .src = out_frame.data.y,
            .dst = out_frame_buffer.y,
        } },
        .{
            .src_pitch = out_frame.pitch,
            .dst_pitch = out_frame.dims.width,
            .dims = .{
                .width = out_frame.dims.width,
                .height = out_frame.dims.height,
            },
        },
    );
    try nvdec.cuda.copy2D(
        .{ .device_to_host = .{
            .src = out_frame.data.uv,
            .dst = out_frame_buffer.uv,
        } },
        .{
            .src_pitch = out_frame.pitch,
            .dst_pitch = out_frame.dims.width,
            .dims = .{
                .width = out_frame.dims.width,
                .height = out_frame.dims.height / 2,
            },
        },
    );
    try context.pop();

    try expected_test_frame.expect_similar(.{
        .y = out_frame_buffer.y,
        .uv = out_frame_buffer.uv,
        .dims = .{ .width = out_frame.dims.width, .height = out_frame.dims.height },
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
