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

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const version = b.option(
        Version,
        "version",
        "Use headers of specified NVIDIA Video Codec SDK version. Note that this does not impact what library verison is loaded since they are loaded dynamically.",
    ) orelse .@"12.2";

    const nvidia_video_codec_sdk = b.addStaticLibrary(.{
        .name = "nvidia_video_codec_sdk",
        .target = target,
        .optimize = optimize,
        // Zig will fail to produce a library without any source code since the linker needs
        // something to link, so we include an empty source file.
        .root_source_file = b.addWriteFiles().add("empty.zig", ""),
    });

    const cuda_root_dir = try getCudaRootDir(b.allocator);
    const cuda_include_dir = try std.fs.path.join(b.allocator, &.{ cuda_root_dir, "include" });
    const cuda_h = try std.fs.path.join(b.allocator, &.{ cuda_include_dir, "cuda.h" });
    const cuda_lib_dir = try std.fs.path.join(b.allocator, &.{ cuda_root_dir, "lib" });

    nvidia_video_codec_sdk.addIncludePath(.{ .cwd_relative = cuda_include_dir });
    nvidia_video_codec_sdk.addLibraryPath(.{ .cwd_relative = cuda_lib_dir });

    nvidia_video_codec_sdk.linkLibC();

    // TODO: There are two strats for linking:
    // - 1. Normal linking assuming the user has everything setup correctly.
    nvidia_video_codec_sdk.linkSystemLibrary("cuda");
    nvidia_video_codec_sdk.linkSystemLibrary("cudart");
    nvidia_video_codec_sdk.linkSystemLibrary("nvcuvid");
    nvidia_video_codec_sdk.linkSystemLibrary("nvidia-encode");
    // TODO: - 2. runtime linking where we link against stubs and then use rpath on the target system:
    // TODO: - 3. linking with the PyPi packages similar to what PyTorch does presently,
    //            this is the same as (2) but then we use specific rpaths (see PyTorch CMake config)

    nvidia_video_codec_sdk.installHeadersDirectory(b.path(version.getIncludeDir()), "", .{});
    // This is a little hacky since we are copying out cuda.h and adding it to the
    // install headers of this library without it even being part of this repo. But
    // without it the SDK headers could not be used since they require cuda.h.
    nvidia_video_codec_sdk.installHeader(.{ .cwd_relative = cuda_h }, "cuda.h");

    // NOTE: We switch terminology here and refer to the entire SDK as "nvcodec".
    // This is also the name we use to refer to the Zig library in general.

    // Bindings

    const nvcodec_bindings = b.addModule("nvcodec_bindings", .{
        .root_source_file = b.path("nvcodec_bindings.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvcodec_bindings.linkLibrary(nvidia_video_codec_sdk);

    // Zig-friendly API

    const nvcodec = b.addModule("nvcodec", .{
        .root_source_file = b.path("nvcodec.zig"),
        .target = target,
        .optimize = optimize,
    });
    nvcodec.addImport("nvcodec_bindings", nvcodec_bindings);

    b.installArtifact(nvidia_video_codec_sdk);
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
