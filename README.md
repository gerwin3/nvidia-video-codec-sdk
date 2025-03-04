# NVIDIA Video Codec SDK for Zig

A wrapper around the NVIDIA Video Codec (NVENC and NVDEC) for Zig.

## Support

| Architecture / OS | Linux | MacOS | Windows |
|-------------------|-------|-------|---------|
| x86               | ✅    | ✅    | ✅      |
| x86_64            | ✅    | ✅    | ✅      |
| arm               | ✅    | ✅    | ❌      |
| aarch64           | ✅    | ✅    | ❌      |

> [!NOTE]  
> Above table reflects the compatibility of the Zig wrapper library itself. There may be additional restrictions with regards to SDK itself.

| Zig version | Status |
|-------------|--------|
| 0.12.0      | ✅     |
| 0.12.1      | ✅     |
| 0.13.0      | ✅     |

This library requires at least:

* CUDA version 10.1 or higher.
* NVIDIA driver 445.87 (Windows), 450.51 (Linux) or higher.

Older versions may work but are not tested.

For more information see the [NVIDIA Driver and CUDA](#nvidia-driver-and-cuda) section.

## Installation

First, update your `build.zig.zon`:

```bash
zig fetch --save git+https://github.com/gerwin3/nvidia-video-codec-sdk.git
```

Add this snippet to your `build.zig` script for NVDEC:

```zig
const nvdec_dep = b.dependency("nvdec", .{
    .target = target,
    .optimize = optimize,
});
your_compilation.root_module.addImport("nvdec", nvdec_dep.module("nvdec"));
```

Add this snippet to your `build.zig` script for NVENC:

```zig
const nvenc_dep = b.dependency("nvenc", .{
    .target = target,
    .optimize = optimize,
});
your_compilation.root_module.addImport("nvenc", nvenc_dep.module("nvenc"));
```

See the `examples` directory for usage.

TODO: Note about `b.dependency("nvdec", .{ ..., .@"add-pypi-rpath" = true, })`.

## NVIDIA Driver and CUDA

This library does not link to the CUDA runtime, the NVDEC and NVENC libraries
at all during build time. Instead, these libraries are loaded during runtime.
Ensure that you have the NVIDIA driver and CUDA installed and they are present
in your library search path. If you have some kind of custom setup you may
patch your `rpath` to direct library loading to the correct path.

Note that many projects choose to link to CUDA stubs during compilation. This
seems unnecessary to me so I opted no to. Instead we rely on `dlopen` and
friends to load NVIDIA dependencies. This is the same approach as taken by
ffmpeg.

### Video Codec SDK Compatibility Matrix

The Zig wrapper is based on the headers of SDK version 12.0. Since all headers
are compatible, this ensures compatibility with the corresponding SDK version,
as well as CUDA and driver versions and above.

For your convenience, find the full compatibility matrix below:

| Video Codec SDK Version | Minimal Driver Version (Windows/Linux) | Minimal CUDA Version |
|-------------------------|----------------------------------------|----------------------|
| 13.0                    | 570.0 / 570.0                          | 11.0                 |
| 12.2                    | 551.76 / 550.54.14                     | 11.0                 |
| 12.1                    | 531.61 / 530.41.03                     | 11.0                 |
| **12.0**                | **522.25 / 520.56.06**                 | **11.0**             |
| 11.1                    | 471.41 / 470.57.02                     | 11.0                 |
| 11.0                    | 456.71 / 455.27                        | 11.0                 |
| 10.0                    | 445.87 / 450.51                        | 10.1                 |
| 9.1                     | 436.15 / 435.21                        | 10.0                 |
| 9.0                     | 418.81 / 418.30                        | 10.0                 |
| 8.2                     | 397.93 / 396.24                        | 8.0                  |
| 8.1                     | 390.77 / 390.25                        | 8.0                  |
| 8.0                     | 378.66 / 378.13                        | 7.5                  |

## License

Licensed under either of

* Apache License, Version 2.0
   ([LICENSE-APACHE](LICENSE-APACHE) or <http://www.apache.org/licenses/LICENSE-2.0>)
* MIT license
   ([LICENSE-MIT](LICENSE-MIT) or <http://opensource.org/licenses/MIT>)

at your option.

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.
