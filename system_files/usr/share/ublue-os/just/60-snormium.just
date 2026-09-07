# Snormium recipes: `ujust snormium-<name>`  — also driven by the Welcome Center
# Set up emulation folders, RetroArch defaults and ES-DE
snormium-emulation:
    snormium-emulation-setup

# Install extra game launchers (Heroic, Lutris, Bottles, Protontricks)
snormium-launchers:
    flatpak install -y --noninteractive flathub com.heroicgameslauncher.hgl net.lutris.Lutris com.usebottles.bottles com.github.Matoking.protontricks

# Install the Creative Studio (GIMP, Krita, Inkscape, Blender, Kdenlive, OBS, Ardour, Audacity)
snormium-creative:
    flatpak install -y --noninteractive --or-update flathub org.gimp.GIMP org.kde.krita org.inkscape.Inkscape org.darktable.Darktable com.rawtherapee.RawTherapee org.upscayl.Upscayl org.blender.Blender org.kde.kdenlive com.obsproject.Studio org.ardour.Ardour org.audacityteam.Audacity

# Low-latency PipeWire profile for USB audio interfaces (undo: ujust snormium-audio-balanced)
snormium-audio-studio:
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    printf 'context.properties = { default.clock.quantum = 64  default.clock.min-quantum = 32 }\n' > ~/.config/pipewire/pipewire.conf.d/snormium-studio.conf
    systemctl --user restart pipewire pipewire-pulse wireplumber

# Back to the balanced audio profile
snormium-audio-balanced:
    rm -f ~/.config/pipewire/pipewire.conf.d/snormium-studio.conf
    systemctl --user restart pipewire pipewire-pulse wireplumber
