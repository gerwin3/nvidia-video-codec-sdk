# nvidia-video-codec-sdk

## Version compat matrix

| Video Codec SDK version | > driver (Windows/Linux) | > CUDA               |
|-------------------------|--------------------------|----------------------|
| 12.2                    | 551.76 / 550.54.14       | 11.0                 |
| 12.1                    | 531.61 / 530.41.03       | 11.0                 |
| 12.0                    | 522.25 / 520.56.06       | 11.0                 |
| 11.1                    | 471.41 / 470.57.02       | 11.0                 |
| 11.0                    | 456.71 / 455.27          | 11.0                 |
| 10.0                    | 445.87 / 450.51          | 10.1                 |
| 9.1                     | 436.15 / 435.21          | 10.0                 |
| 9.0                     | 418.81 / 418.30          | 10.0                 |
| 8.2                     | 397.93 / 396.24          | 8.0                  |
| 8.1                     | 390.77 / 390.25          | 8.0                  |
| 8.0                     | 378.66 / 378.13          | 7.5                  |

> All NVDECODE APIs are exposed in two header-files: cuviddec.h and nvcuvid.h. These headers can be found under Interface folder in the Video Codec SDK package. The samples in NVIDIA Video Codec SDK statically load the library (which ships as a part of the SDK package for windows) functions and include cuviddec.h and nvcuvid.h in the source files. The Windows DLL nvcuvid.dll is included in the NVIDIA display driver for Windows. The Linux library libnvcuvid.so is included with NVIDIA display driver for Linux. 

-- NVIDIA docs
