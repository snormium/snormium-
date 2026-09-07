# Creative Studio
Installed on first boot (Flathub, sandboxed, auto-updating):
| Area | Apps |
|---|---|
| Photo & image | GIMP (raster editing), Krita (painting/illustration), Inkscape (vector/SVG), Darktable and RawTherapee (RAW workflow), Upscayl (AI upscaling) |
| Video | Kdenlive (editing), OBS Studio with game-capture and VA-API encode plugins (recording/streaming) |
| 3D | Blender |
| Audio | Ardour (DAW), Audacity (editing); PipeWire "Studio audio mode" in Welcome for low-latency interfaces |
| Command line | ImageMagick (`magick`), ffmpeg — native, full codecs |

**DaVinci Resolve** (free and Studio) is not redistributable, so it is not bundled. Download the Linux `.run` installer from
blackmagicdesign.com to `~/Downloads`, then Welcome ▸ *DaVinci Resolve* (or `ujust install-resolve`). It runs in a Distrobox
container with the libraries Resolve expects; the launcher appears in the menu when done. GPU: works on NVIDIA (CUDA) and AMD
(ROCm/OpenCL) cards; Intel iGPUs are not supported by Resolve on Linux.
