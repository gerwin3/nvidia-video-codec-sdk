//! Example to show how to decode a file.

const std = @import("std");

const nvdec = @import("nvdec");

const width = 1920;
const height = 1080;

const y_plane_width = width;
const y_plane_height = height;
const uv_plane_width = width;
const uv_plane_height = height / 2;

var frame_buffer: ?struct {
    y: []u8,
    uv: []u8,
} = null;

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    frame_buffer = .{
        .y = try allocator.alloc(u8, y_plane_width * y_plane_height),
        .uv = try allocator.alloc(u8, uv_plane_width * uv_plane_height),
    };
    defer {
        allocator.free(frame_buffer.?.y);
        allocator.free(frame_buffer.?.uv);
    }

    try nvdec.cuda.load();
    try nvdec.cuda.init();
    try nvdec.load();

    var context = try nvdec.cuda.Context.init(0);
    defer context.deinit();

    var decoder = try nvdec.Decoder.create(&context, .{ .codec = .h264 }, allocator);
    defer decoder.destroy();

    const file = try std.fs.cwd().openFile("rainbow.264", .{});
    defer file.close();

    var buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    var nal = std.ArrayList(u8).init(allocator);
    defer nal.deinit();

    while (true) {
        const len = try file.reader().readAll(buffer);

        var last_nal: usize = 0;

        const len_range = @max(len, 4) - 4;
        for (0..len_range) |index| {
            if (std.mem.eql(u8, buffer[index .. index + 4], &.{ 0, 0, 0, 1 })) {
                if (index - last_nal > 0) {
                    nal.appendSlice(buffer[last_nal..index]) catch @panic("oom");
                }
                if (nal.items.len > 0) {
                    if (try decoder.decode(nal.items)) |frame| {
                        try handle_frame(decoder.context, &frame);
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

    if (try decoder.decode(nal.items)) |frame| {
        try handle_frame(decoder.context, &frame);
    }

    while (try decoder.flush()) |frame| {
        try handle_frame(decoder.context, &frame);
    }
}

/// Print YUV values of the frame.
fn handle_frame(cuda_context: *nvdec.cuda.Context, frame: *const nvdec.Frame) !void {
    std.debug.assert(frame.dims.width == width);
    std.debug.assert(frame.dims.height == height);

    try cuda_context.push();

    try nvdec.cuda.copy2D(
        .{ .device_to_host = .{
            .src = frame.data.y,
            .dst = frame_buffer.?.y,
        } },
        .{
            .src_pitch = frame.pitch,
            .dst_pitch = y_plane_width,
            .dims = .{
                .width = y_plane_width,
                .height = y_plane_height,
            },
        },
    );

    try nvdec.cuda.copy2D(
        .{ .device_to_host = .{
            .src = frame.data.uv,
            .dst = frame_buffer.?.uv,
        } },
        .{
            .src_pitch = frame.pitch,
            .dst_pitch = uv_plane_width,
            .dims = .{
                .width = uv_plane_width,
                .height = uv_plane_height,
            },
        },
    );

    std.debug.print("yuv = ({}, {}, {})\n", .{
        frame_buffer.?.y[0],
        frame_buffer.?.uv[0],
        frame_buffer.?.uv[1],
    });

    try cuda_context.push();
}
