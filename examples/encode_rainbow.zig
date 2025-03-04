const std = @import("std");

const nvenc = @import("nvenc");

const rainbow = @import("common/color_space_utils.zig").rainbow;

const rainbow_num_frames = 256;

const width = 1920;
const height = 1080;

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    try nvenc.cuda.load();
    try nvenc.cuda.init();
    try nvenc.load();

    var context = try nvenc.cuda.Context.init(0);
    defer context.deinit();

    const file = try std.fs.cwd().createFile("rainbow.264", .{});
    defer file.close();
    const writer = file.writer();

    var encoder = try nvenc.Encoder.init(
        &context,
        .{
            .codec = .{ .h264 = .{} },
            .resolution = .{ .width = 1920, .height = 1080 },
        },
        allocator,
    );
    defer encoder.deinit();

    std.debug.print("parameter sets: {any}\n", .{encoder.parameter_sets});

    const frame_buffer_luma = try allocator.alloc(u8, height * width);
    defer allocator.free(frame_buffer_luma);
    const frame_buffer_chroma = try allocator.alloc(u8, (height / 2) * width);
    defer allocator.free(frame_buffer_chroma);

    try context.push();
    var frame = try nvenc.Frame.alloc(width, height, 0);
    defer {
        context.push() catch unreachable;
        frame.free();
        context.pop() catch unreachable;
    }
    try context.pop();

    for (0..rainbow_num_frames) |i| {
        frame.timestamp = i * 33;

        const r = rainbow(i, rainbow_num_frames);
        @memset(frame_buffer_luma, r.y);
        for (0.., frame_buffer_chroma) |index, _| {
            frame_buffer_chroma[index] = if (index % 2 == 0) r.u else r.v;
        }

        try context.push();
        try frame.copy_from_host(.{ .luma = frame_buffer_luma, .chroma = frame_buffer_chroma });
        try context.pop();

        try encoder.encode(&frame, writer);
    }

    try encoder.flush(writer);
}
