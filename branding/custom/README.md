# Custom art drop-in
Anything placed here overrides the generated defaults at build time:

| File | Used as |
|------|---------|
| `logo.svg` (or `logo.png`) | app icon, menu icon, greeter logo, Plymouth logo, installer slideshow icon |
| `wallpaper.png` / `wallpaper.jpg` | default desktop background |
| any other `*.png` / `*.jpg` | extra wallpapers (Backgrounds ▸ Snormium) |
| `plymouth-background.png` | optional Plymouth background image |
| `sidebar-logo.svg` (260×80) | installer (Anaconda) sidebar logo/wordmark |

`build.sh` fills this folder automatically from `~/Downloads` (see `build.sh --help`).
If the folder is empty, the procedural nucleus wallpaper and the SVG logo in `branding/` are used.
