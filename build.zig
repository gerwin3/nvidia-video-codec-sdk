const std = @import("std");

// TODO: There are two strats for linking:
// - 1. Normal linking assuming the user has everything setup correctly. (this is what we do now)
// - 2. runtime linking where we link against stubs and then use rpath on the target system:
// - 3. linking with the PyPi packages similar to what PyTorch does presently,
//      this is the same as (2) but then we use specific rpaths (see PyTorch CMake config)
// We want this to be configurable later

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    addNvDec(b, target, optimize);
    addNvEnc(b, target, optimize);
}

fn addNvDec(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const nvdec_bindings = b.addModule("nvdec_bindings", .{
        .root_source_file = b.path("nvdec_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    // We will be loading the NVIDIA libraries dynamically but they still require libc.
    // Settings link_libc = true here will cause libc to be linked by dependents even
    // though we are exporting a module rather than a library.
    nvdec_bindings.link_libc = true;

    // Zig-friendly wrapper module

    const nvdec = b.addModule("nvdec", .{
        .root_source_file = b.path("nvdec.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvdec.addImport("nvdec_bindings", nvdec_bindings);
}

fn addNvEnc(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) void {
    const nvenc_bindings = b.addModule("nvenc_bindings", .{
        .root_source_file = b.path("nvenc_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    // We will be loading the NVIDIA libraries dynamically but they still require libc.
    // Settings link_libc = true here will cause libc to be linked by dependents even
    // though we are exporting a module rather than a library.
    nvenc_bindings.link_libc = true;

    // Zig-friendly wrapper module
    const nvenc = b.addModule("nvenc", .{
        .root_source_file = b.path("nvenc.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvenc.addImport("nvenc_bindings", nvenc_bindings);
}
