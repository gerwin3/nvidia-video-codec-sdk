const std = @import("std");

const nvenc = @import("nvenc");

const rainbow = @import("common/color_space_utils.zig").rainbow;

const rainbow_num_frames = 256;

const width = 1920;
const height = 1080;

const num_planes = 3;

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

    std.debug.print("parameter sets: {any}", .{encoder.parameter_sets});

    var frame_buffer_host = try allocator.alloc(u8, num_planes * height * width);
    defer allocator.free(frame_buffer_host);
    const plane_size = height * width;
    const y_plane = frame_buffer_host[0 * plane_size .. 1 * plane_size];
    const u_plane = frame_buffer_host[1 * plane_size .. 2 * plane_size];
    const v_plane = frame_buffer_host[2 * plane_size .. 3 * plane_size];

    const frame_buffer_device = try nvenc.cuda.allocPitch(width, num_planes * height, 1);
    defer nvenc.cuda.free(frame_buffer_device.ptr);

    const frame = nvenc.Frame{
        .data = frame_buffer_device.ptr,
        .format = .yuv444,
        .pitch = @intCast(frame_buffer_device.pitch),
        .dims = .{
            .width = width,
            .height = height,
        },
    };

    for (0..rainbow_num_frames) |i| {
        const r = rainbow(i, rainbow_num_frames);

        // TODO: timestamp

        @memset(y_plane, r.y);
        @memset(u_plane, r.u);
        @memset(v_plane, r.v);

        try nvenc.cuda.copy2D(
            .{
                .host_to_device = .{
                    .src = frame_buffer_host,
                    .dst = frame.data,
                },
            },
            .{
                .src_pitch = width,
                .dst_pitch = frame.data,
                .dims = .{
                    .width = width,
                    .height = 3 * height,
                },
            },
        );

        try encoder.encode(&frame, writer);
    }
}
