const std = @import("std");

const nvenc = @import("nvenc");

const rainbow = @import("common/color_space_utils.zig").rainbow;

const rainbow_num_frames = 256;

const width = 1920;
const height = 1080;

const y_plane_width = width;
const y_plane_height = height;
const uv_plane_width = width;
const uv_plane_height = height / 2;

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

    var frame_data_host = try allocator.alloc(u8, (y_plane_height + uv_plane_height) * width);
    defer allocator.free(frame_data_host);
    const y_plane = frame_data_host[0 .. y_plane_height * y_plane_width];
    const uv_plane = frame_data_host[y_plane_height * y_plane_width ..];

    try context.push();
    const frame_data_device = try nvenc.cuda.allocPitch(width, (y_plane_height + uv_plane_height), .element_size_4);
    defer {
        context.push() catch unreachable;
        nvenc.cuda.free(frame_data_device.ptr);
        context.pop() catch unreachable;
    }
    try context.pop();

    var frame = nvenc.Frame{
        .data = frame_data_device.ptr,
        .format = .nv12,
        .pitch = @intCast(frame_data_device.pitch),
        .dims = .{
            .width = width,
            .height = height,
        },
        .timestamp = 0,
    };

    for (0..rainbow_num_frames) |i| {
        frame.timestamp = i * 33;

        const r = rainbow(i, rainbow_num_frames);
        @memset(y_plane, r.y);
        for (0.., uv_plane) |uv_plane_index, _| {
            uv_plane[uv_plane_index] = if (uv_plane_index % 2 == 0) r.u else r.v;
        }

        try context.push();
        try nvenc.cuda.copy2D(
            .{
                .host_to_device = .{
                    .src = frame_data_host,
                    .dst = frame.data,
                },
            },
            .{
                .src_pitch = width,
                .dst_pitch = frame.pitch,
                .dims = .{
                    .width = width,
                    .height = (y_plane_height + uv_plane_height),
                },
            },
        );
        try context.pop();

        try encoder.encode(&frame, writer);
    }
}
