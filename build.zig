const std = @import("std");

pub fn build(b: *std.Build) !void {
    const add_pypi_rpath = b.option(bool, "add-pypi-rpath", "Add PyPI rpaths to enable loading CUDA from PyPI install. This option only makes sense if the dependent library is a Python package.") orelse false;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cuda_modules = addCuda(b, target, optimize);
    const nvdec = addNvDec(b, target, optimize, cuda_modules);
    const nvenc = addNvEnc(b, target, optimize, cuda_modules);

    const modules = .{ nvdec, nvenc };
    inline for (modules) |module| {
        if (add_pypi_rpath) {
            // Through this trick any downstream library that uses nvdec or nvenc will automatically
            // have extra rpaths which will allow it to load from the PyPI installation location, assuming
            // the library is installed through PyPI as well.
            switch (target.result.os.tag) {
                .linux => module.addRPathSpecial("$ORIGIN/../../nvidia/cuda_runtime/lib"),
                .macos => module.addRPathSpecial("@loader_path/../../nvidia/cuda_runtime/lib"),
                .windows => module.addRPathSpecial("../../nvidia/cuda_runtime/lib"),
                else => module.addRPathSpecial("../../nvidia/cuda_runtime/lib"),
            }
        }
    }
}

const CudaModules = struct {
    cuda_bindings: *std.Build.Module,
    cuda: *std.Build.Module,
};

fn addCuda(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) CudaModules {
    const cuda_bindings = b.addModule("cuda_bindings", .{
        .root_source_file = b.path("cuda_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    // We will be loading the NVIDIA libraries dynamically but they still require libc.
    // Settings link_libc = true here will cause libc to be linked by dependents even
    // though we are exporting a module rather than a library.
    cuda_bindings.link_libc = true;

    // Zig-friendly wrapper module
    const cuda = b.addModule("cuda", .{
        .root_source_file = b.path("cuda.zig"),
        .target = target,
        .optimize = optimize,
    });
    cuda.addImport("cuda_bindings", cuda_bindings);

    return .{
        .cuda = cuda,
        .cuda_bindings = cuda_bindings,
    };
}

fn addNvDec(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    cuda_modules: CudaModules,
) *std.Build.Module {
    const nvdec_bindings = b.addModule("nvdec_bindings", .{
        .root_source_file = b.path("nvdec_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvdec_bindings.addImport("cuda_bindings", cuda_modules.cuda_bindings);
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
    nvdec.addImport("cuda", cuda_modules.cuda);
    nvdec.addImport("nvdec_bindings", nvdec_bindings);

    // Example
    const example_decode_rainbow = b.addExecutable(.{
        .name = "example_decode_rainbow",
        .root_source_file = b.path("examples/decode_rainbow.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_decode_rainbow.root_module.addImport("nvdec", nvdec);
    b.installArtifact(example_decode_rainbow);

    return nvdec;
}

fn addNvEnc(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    cuda_modules: CudaModules,
) *std.Build.Module {
    const nvenc_bindings = b.addModule("nvenc_bindings", .{
        .root_source_file = b.path("nvenc_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvenc_bindings.addImport("cuda_bindings", cuda_modules.cuda_bindings);
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
    nvenc.addImport("cuda", cuda_modules.cuda);
    nvenc.addImport("nvenc_bindings", nvenc_bindings);

    // Example
    const example_encode_rainbow = b.addExecutable(.{
        .name = "example_encode_rainbow",
        .root_source_file = b.path("examples/encode_rainbow.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_encode_rainbow.root_module.addImport("nvenc", nvenc);
    b.installArtifact(example_encode_rainbow);

    return nvenc;
}
