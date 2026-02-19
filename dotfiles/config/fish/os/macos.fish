# macOS-specific paths
set -l macos_paths \
    /opt/homebrew/sbin \
    /opt/homebrew/bin \
    /usr/local/bin \
    ~/.rustup/toolchains/nightly-aarch64-apple-darwin/bin \
    ~/.local/share/cargo/bin \
    ~/Library/Android/Sdk/emulator \
    ~/Library/Android/Sdk/platform-tools \
    ~/.sdk/flutter/bin \
    ~/.zvm/bin \
    ~/.zvm/self \
    /opt/homebrew/anaconda3/bin \
    /opt/homebrew/anaconda3/envs/myenv/bin \
    ~/.bin/nvim/bin

for p in $macos_paths
    test -d $p; and fish_add_path --move --path $p
end

# Android SDK
set -gx ANDROID_SDK_ROOT "$HOME/Library/Android/sdk"
set -gx ANDROID_HOME /opt/homebrew/share/android-commandlinetools

# Vulkan (MoltenVK)
set -gx VK_ICD_FILENAMES /opt/homebrew/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json

# Browser
set -gx BROWSER open

# Conda (lazy-load)
set -gx CONDA_EXE $HOME/.anaconda3/bin/conda
set -gx CONDA_PREFIX $HOME/.anaconda3

function conda --description 'Lazy-load conda on first use'
    functions -e conda
    eval $CONDA_EXE "shell.fish" "hook" $argv | source
    conda $argv
end

# macOS aliases
alias hms="sudo darwin-rebuild switch --flake ~/.config/nix#nathaniels-MacBook-Pro"
alias hh="sudo darwin-rebuild switch --flake ~/.config/nix#nathaniels-MacBook-Pro --fast"
alias j8="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
alias j17="JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home"
alias j21="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home"
alias j24="JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home"

# Vulkan function
function vk --description 'Run command with Vulkan/MoltenVK environment'
    set -lx VK_ICD_FILENAMES /opt/homebrew/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json
    set -lx DYLD_FALLBACK_LIBRARY_PATH /opt/homebrew/opt/vulkan-loader/lib /opt/homebrew/opt/molten-vk/lib
    set -lx MTL_HUD_ENABLED 1
    $argv
end
