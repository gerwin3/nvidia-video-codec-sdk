const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cuda_root_dir = try getCudaRootDir(b.allocator);
    const cuda_lib_dir = try std.fs.path.join(b.allocator, &.{ cuda_root_dir, "lib" });

    lib.addLibraryPath(.{ .cwd_relative = cuda_lib_dir });
    lib.linkLibC();
    // exe.linkSystemLibrary("cuda"); TODO necessary?
    // exe.linkSystemLibrary("cudart");
    // exe.linkSystemLibrary("cuvid");
    // exe.linkSystemLibrary("nvenc"); ?
    // TODO: rpath magic to load PyPi versions

    b.installArtifact(lib);
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
