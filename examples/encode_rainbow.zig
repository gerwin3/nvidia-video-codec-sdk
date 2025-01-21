const std = @import("std");

const nvenc = @import("nvenc");

const rainbow = @import("common/color_space_utils.zig").rainbow;

const rainbow_num_frames = 256;

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
    _ = writer; // TODO

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

    // var frame = try nvenc.Frame.alloc(1920, 1080, allocator);
    // defer frame.free(allocator);
    //
    // for (0..rainbow_num_frames) |i| {
    //     const r = rainbow(i, rainbow_num_frames);
    //     frame.timestamp = i * 33;
    //     @memset(frame.data.y, r.y);
    //     @memset(frame.data.u, r.u);
    //     @memset(frame.data.v, r.v);
    //     try encoder.encode(&frame, writer);
    // }
}
