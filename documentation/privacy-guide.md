# Privacy
Snormium collects nothing and phones nowhere: no telemetry, no accounts, no error reporting upload (Mint's `mintreport`
only shows local reports). Update checks contact Mint/Ubuntu/Flathub mirrors.
* System Settings ▸ **Privacy**: recent-files history, camera/microphone/location for portal-aware apps, connectivity checks.
* **Flatseal** (Security Center ▸ Advanced) edits per-app Flatpak permissions (camera, mic, network, folders) — this is where
  you deny Discord the microphone or a launcher your Documents.
* Browser: Firefox ships Mint's privacy defaults (tracking protection strict optional in Firefox settings).
* Diagnostics are never sent automatically; `mintreport` is opt-in and local.
