const std = @import("std");

/// NVIDIA Video Codec SDK version.
///
/// Note that this does NOT correspond to the CUDA version in any way.
pub const Version = enum {
    @"9.0",
    @"9.1",
    @"10.0",
    @"11.0",
    @"11.1",
    @"12.0",
    @"12.1",
    @"12.2",

    fn getIncludeDir(self: Version) []const u8 {
        return switch (self) {
            .@"9.0" => "include/v9.0.20",
            .@"9.1" => "include/v9.1.23",
            .@"10.0" => "include/v10.0.26",
            .@"11.0" => "include/v11.0.10",
            .@"11.1" => "include/v11.1.5",
            .@"12.0" => "include/v12.0.16",
            .@"12.1" => "include/v12.1.14",
            .@"12.2" => "include/v12.2.72",
        };
    }
};

// TODO: There are two strats for linking:
// - 1. Normal linking assuming the user has everything setup correctly. (this is what we do now)
// - 2. runtime linking where we link against stubs and then use rpath on the target system:
// - 3. linking with the PyPi packages similar to what PyTorch does presently,
//      this is the same as (2) but then we use specific rpaths (see PyTorch CMake config)
// We want this to be configurable later

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = b.option(
        Version,
        "version",
        "Use headers of specified NVIDIA Video Codec SDK version. Note that this does not impact what library verison is loaded since they are loaded dynamically.",
    ) orelse .@"12.2";

    const cuda_paths = try getCudaPaths(b);

    addDecodingLibraryAndBindings(b, target, optimize, version, &cuda_paths);
    addEncodingLibraryAndBindings(b, target, optimize, version, &cuda_paths);
}

fn addDecodingLibraryAndBindings(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    version: Version,
    cuda_paths: *const CudaPaths,
) void {
    const lib_nvdec = b.addStaticLibrary(.{
        .name = "nvdec",
        .target = target,
        .optimize = optimize,
        // Zig will fail to produce a library without any source code since the linker needs
        // something to link, so we include an empty source file.
        .root_source_file = b.addWriteFiles().add("empty.zig", ""),
    });

    lib_nvdec.addIncludePath(.{ .cwd_relative = cuda_paths.include_dir });
    lib_nvdec.addLibraryPath(.{ .cwd_relative = cuda_paths.lib_dir });
    lib_nvdec.linkLibC();
    lib_nvdec.linkSystemLibrary("cuda");
    lib_nvdec.linkSystemLibrary("cudart");
    lib_nvdec.linkSystemLibrary("nvcuvid");
    lib_nvdec.installHeader(b.path(b.pathJoin(&.{ version.getIncludeDir(), "cuviddec.h" })), "cuviddec.h");
    lib_nvdec.installHeader(b.path(b.pathJoin(&.{ version.getIncludeDir(), "nvcuvid.h" })), "nvcuvid.h");
    // This is a little hacky since we are copying out cuda.h and adding it to the
    // install headers of this library without it even being part of this repo. But
    // without it the SDK headers could not be used since they require cuda.h.
    lib_nvdec.installHeader(.{ .cwd_relative = cuda_paths.cuda_h }, "cuda.h");

    b.installArtifact(lib_nvdec);

    // Raw bindings
    const nvdec_bindings = b.addModule("nvdec_bindings", .{
        .root_source_file = b.path("nvdec_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvdec_bindings.linkLibrary(lib_nvdec);

    // Zig-friendly API
    const nvdec = b.addModule("nvdec", .{
        .root_source_file = b.path("nvdec.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvdec.addImport("nvdec_bindings", nvdec_bindings);
}

fn addEncodingLibraryAndBindings(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    version: Version,
    cuda_paths: *const CudaPaths,
) void {
    const lib_nvenc = b.addStaticLibrary(.{
        .name = "nvenc",
        .target = target,
        .optimize = optimize,
        // Zig will fail to produce a library without any source code since the linker needs
        // something to link, so we include an empty source file.
        .root_source_file = b.addWriteFiles().add("empty.zig", ""),
    });

    lib_nvenc.addIncludePath(.{ .cwd_relative = cuda_paths.include_dir });
    lib_nvenc.addLibraryPath(.{ .cwd_relative = cuda_paths.lib_dir });
    lib_nvenc.linkLibC();
    lib_nvenc.linkSystemLibrary("cuda");
    lib_nvenc.linkSystemLibrary("cudart");
    lib_nvenc.linkSystemLibrary("nvidia-encode");
    lib_nvenc.installHeader(b.path(b.pathJoin(&.{ version.getIncludeDir(), "nvEncodeAPI.h" })), "nvEncodeAPI.h");

    // Raw bindings
    const nvenc_bindings = b.addModule("nvenc_bindings", .{
        .root_source_file = b.path("nvenc_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvenc_bindings.linkLibrary(lib_nvenc);

    // Zig-friendly API
    const nvenc = b.addModule("nvenc", .{
        .root_source_file = b.path("nvenc.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvenc.addImport("nvenc_bindings", nvenc_bindings);

    b.installArtifact(lib_nvenc);
}

const CudaPaths = struct {
    root_dir: []const u8,
    include_dir: []const u8,
    cuda_h: []const u8,
    lib_dir: []const u8,
};

fn getCudaPaths(b: *std.Build) !CudaPaths {
    const root_dir = try getCudaRootDir(b.allocator);
    const include_dir = try std.fs.path.join(b.allocator, &.{ root_dir, "include" });
    return .{
        .root_dir = root_dir,
        .include_dir = include_dir,
        .cuda_h = try std.fs.path.join(b.allocator, &.{ include_dir, "cuda.h" }),
        .lib_dir = try std.fs.path.join(b.allocator, &.{ root_dir, "lib" }),
    };
}

fn getCudaRootDir(allocator: std.mem.Allocator) ![]const u8 {
    if (try getCudaRootDirByEnv(allocator)) |dir| {
        return dir;
    }
    if (getCudaRootDirByBruteForce()) |dir| {
        return dir;
    }
    return error.CudaRootDirNotFound;
}

fn getCudaRootDirByEnv(allocator: std.mem.Allocator) !?[]const u8 {
    if (std.process.getEnvVarOwned(allocator, "CUDA_PATH")) |env| {
        return env;
    } else |err| if (err != error.EnvironmentVariableNotFound) {
        return err;
    } else {
        return null;
    }
}

fn getCudaRootDirByBruteForce() ?[]const u8 {
    const cuda_root_dirs = [_][]const u8{
        "/usr",
        "/usr/local",
        "/usr/local/cuda",
        "/opt/cuda",
    };
    inline for (cuda_root_dirs) |cuda_root_dir| {
        const cuda_test_header = cuda_root_dir ++ "/include/cuda.h";
        if (std.fs.openFileAbsolute(cuda_test_header, .{})) |file| {
            file.close();
            return cuda_root_dir;
        } else |_| {}
    }
    return null;
}
