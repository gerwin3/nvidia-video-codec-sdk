//! Example to show how to decode a file.

const std = @import("std");

const nvdec = @import("nvdec");

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const allocator = general_purpose_allocator.allocator();

    try nvdec.cuda.load();
    try nvdec.cuda.init();
    try nvdec.load();

    var decoder = try nvdec.Decoder.create(.{
        .codec = .h264,
        .resolution = .{ .width = 1920, .height = 1080 },
    }, allocator);
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
                        try handle_frame(decoder.context, frame);
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
        try handle_frame(decoder.context, frame);
    }

    while (try decoder.flush()) |frame| {
        try handle_frame(decoder.context, frame);
    }
}

/// Print YUV values of the frame.
fn handle_frame(cuda_context: nvdec.cuda.Context, frame: *const nvdec.Frame) !void {
    try cuda_context.push();

    try nvdec.cuda.copy2D(
        .device_to_host{
            .src = frame.y,
            .dst = xxx,
        },
        frame.pitch,
        frame.dims.width,
        frame.dims.height,
    );

    try nvdec.cuda.copy2D(
        .device_to_host{
            .src = frame.y,
            .dst = xxx,
        },
        frame.pitch,
        frame.dims.width,
        frame.dims.height,
    );

    std.debug.print("yuv = ({}, {}, {})\n", .{
        frame.data.y[0],
        frame.data.uv[0],
        frame.data.uv[1],
    });

    try cuda_context.push();
}
