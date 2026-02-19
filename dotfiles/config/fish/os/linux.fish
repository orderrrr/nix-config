# Linux-specific paths
set -l linux_paths \
    ~/.cargo/bin \
    ~/.local/bin \
    ~/.local/share/cargo/bin \
    /usr/local/bin

for p in $linux_paths
    test -d $p; and fish_add_path --move --path $p
end

# Vulkan
set -gx VULKAN_HOME /usr/share/vulkan
set -gx VULKAN_SDK /usr

# Browser
set -gx BROWSER xdg-open

# Linux aliases
alias hms="home-manager switch --flake ~/.config/nix"

# Hyprland specific
if test -n "$HYPRLAND_INSTANCE_SIGNATURE"
    set -gx WAYLAND_DISPLAY "wayland-1"
end