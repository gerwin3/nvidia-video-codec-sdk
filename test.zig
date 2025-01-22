const std = @import("std");

const cuda = @import("cuda");
const nvenc = @import("nvenc");
const nvdec = @import("nvdec");

const TestColor = enum {
    red,
    green,
    blue,
    pink,

    fn to_yuv(self: TestColor) []f32 {
        return switch (self) {
            .red => rgb2yuv(255.0, 0.0, 0.0),
            .green => rgb2yuv(0.0, 255.0, 0.0),
            .blue => rgb2yuv(0.0, 0.0, 255.0),
            .pink => rgb2yuv(255.0, 0.0, 255.0),
        };
    }

    fn from_yuv(yuv: []f32) ?TestColor {
        const epsilon = 1.0;
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
                uv_plane[((dims.width / 2) * y) + x] = yuv[1];
                uv_plane[((dims.width / 2) * y) + x + 1] = yuv[1];
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
        const q1_index_y = ((frame.height / 4) * frame.pitch) + frame.width / 4;
        const q2_index_y = ((frame.height / 4) * frame.pitch) + frame.width / 4 * 3;
        const q3_index_y = ((frame.height / 4 * 3) * frame.pitch) + frame.width / 4;
        const q4_index_y = ((frame.height / 4 * 3) * frame.pitch) + frame.width / 4 * 3;
        const q1_index_uv = ((frame.height / 2 / 4) * frame.pitch) + frame.width / 4;
        const q2_index_uv = ((frame.height / 2 / 4) * frame.pitch) + frame.width / 4 * 3;
        const q3_index_uv = ((frame.height / 2 / 4 * 3) * frame.pitch) + frame.width / 4;
        const q4_index_uv = ((frame.height / 2 / 4 * 3) * frame.pitch) + frame.width / 4 * 3;
        const q1 = .{ frame.data.y[q1_index_y], frame.data.uv[q1_index_uv], frame.data.uv[q1_index_uv + 1] };
        const q2 = .{ frame.data.y[q2_index_y], frame.data.uv[q2_index_uv], frame.data.uv[q2_index_uv + 1] };
        const q3 = .{ frame.data.y[q3_index_y], frame.data.uv[q3_index_uv], frame.data.uv[q3_index_uv + 1] };
        const q4 = .{ frame.data.y[q4_index_y], frame.data.uv[q4_index_uv], frame.data.uv[q4_index_uv + 1] };
        try std.testing.expectEqual(@as(?TestColor, self.q1), TestColor.from_yuv(color_f32(q1)));
        try std.testing.expectEqual(@as(?TestColor, self.q2), TestColor.from_yuv(color_f32(q2)));
        try std.testing.expectEqual(@as(?TestColor, self.q3), TestColor.from_yuv(color_f32(q3)));
        try std.testing.expectEqual(@as(?TestColor, self.q4), TestColor.from_yuv(color_f32(q4)));
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

fn test_encoder_decoder(encoder_options: nvenc.EncoderOptions, num_frames: usize) !void {
    const allocator = std.testing.allocator;

    try init();

    var context = try cuda.Context.init(0);
    defer context.deinit();

    var encoder = try nvenc.Encoder.init(&context, encoder_options, allocator);
    defer encoder.deinit();

    const decoder_codec = switch (encoder_options.codec) {
        .h264 => nvdec.Codec.h264,
        .hevc => nvdec.Codec.hevc,
    };

    var decoder = try nvdec.Decoder.create(&context, .{ .codec = decoder_codec }, allocator);
    defer decoder.destroy();

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
        try encoder.encode(&in_frame, bitstream.writer());
    }

    test_frames.reset();

    var buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    var nal = std.ArrayList(u8).init(allocator);
    defer nal.deinit();

    while (true) {
        const len = try bitstream.reader().readAll(buffer);

        var last_nal: usize = 0;

        const len_range = @max(len, 4) - 4;
        for (0..len_range) |index| {
            if (std.mem.eql(u8, buffer[index .. index + 4], &.{ 0, 0, 0, 1 })) {
                if (index - last_nal > 0) {
                    nal.appendSlice(buffer[last_nal..index]) catch @panic("oom");
                }
                if (nal.items.len > 0) {
                    if (try decoder.decode(nal.items)) |out_frame| {
                        try test_expected_frame(decoder.context, &out_frame);
                    }
                    nal.clearRetainingCapacity();
                    last_nal = index;
                }
            }
        }

        if (last_nal < len) {
            nal.appendSlice(buffer[last_nal..len]) catch @panic("oom");
        }

        if (len < buffer.len) break;
    }

    if (try decoder.decode(nal.items)) |out_frame| {
        try test_expected_frame(decoder.context, &out_frame);
    }

    while (try decoder.flush()) |out_frame| {
        try test_expected_frame(decoder.context, &out_frame);
    }

    std.testing.expectEqual(test_frames.next(), @as(?TestFrame, null));
}

fn test_expected_frame(
    context: *cuda.Context,
    test_frames_it: *TestFrameIterator,
    frame: *const nvdec.Frame,
) !void {
    const static: struct {
        var out_frame_buffer: ?struct { y: []u8, uv: []u8 } = null;
    } = .{};

    if (test_frames_it.next()) |expected_test_frame| {
        try context.push();

        try nvdec.cuda.copy2D(
            .{ .device_to_host = .{
                .src = frame.data.y,
                .dst = static.frame_buffer.?.y,
            } },
            .{
                .src_pitch = frame.pitch,
                .dst_pitch = frame.dims.width,
                .dims = .{
                    .width = frame.dims.width,
                    .height = frame.dims.height,
                },
            },
        );

        try nvdec.cuda.copy2D(
            .{ .device_to_host = .{
                .src = frame.data.uv,
                .dst = static.frame_buffer.?.uv,
            } },
            .{
                .src_pitch = frame.pitch,
                .dst_pitch = frame.width,
                .dims = .{
                    .width = frame.width,
                    .height = frame.height / 2,
                },
            },
        );

        // TODO:
        // std.debug.print("yuv = ({}, {}, {})\n", .{
        //     frame_buffer.?.y[0],
        //     frame_buffer.?.uv[0],
        //     frame_buffer.?.uv[1],
        // });

        try context.pop();

        try expected_test_frame.expect_similar(.{
            .y = static.out_frame_buffer.y,
            .uv = static.out_frame_buffer.uv,
            .dims = .{ .width = frame.width, .height = frame.height },
        });
    } else {
        try std.testing.expect(false);
    }
}

fn init() !void {
    var static: struct {
        var is_initialized = false;
    } = .{};

    if (!static.is_initialized) {
        try cuda.load();
        try cuda.init();
        try nvenc.load();
        try nvdec.load();
        static.is_initialized = true;
    }
}

pub fn rgb2yuv(r: f32, g: f32, b: f32) [3]f32 {
    return .{
        0.257 * r + 0.504 * g + 0.098 * b + 16.0,
        -0.148 * r - 0.291 * g + 0.439 * b + 128.0,
        0.439 * r - 0.368 * g - 0.071 * b + 128.0,
    };
}

pub fn yuv2rgb(y: f32, u: f32, v: f32) [3]f32 {
    y -= 16.0;
    u -= 128.0;
    v -= 128.0;
    return .{
        1.164 * y + 1.596 * v,
        1.164 * y - 0.392 * u - 0.813 * v,
        1.164 * y + 2.017 * u,
    };
}

pub fn color_f32(color: [3]u8) [3]f32 {
    return .{
        @floatFromInt(color[0]),
        @floatFromInt(color[1]),
        @floatFromInt(color[2]),
    };
}

pub fn color_bytes(color: [3]f32) [3]u8 {
    return .{
        @intFromFloat(color[0]),
        @intFromFloat(color[1]),
        @intFromFloat(color[2]),
    };
}
