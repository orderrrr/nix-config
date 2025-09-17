#!/usr/bin/env zsh

# Neovim Nightly Installer Script
# Platform-agnostic installer for macOS and Linux

# Enable extended globbing and error handling
setopt EXTENDED_GLOB NULL_GLOB
set -euo pipefail

# Color codes for output (zsh-specific associative array)
typeset -A colors
colors=(
    red     $'\033[31m'
    green   $'\033[32m'
    yellow  $'\033[33m'
    blue    $'\033[34m'
    magenta $'\033[35m'
    cyan    $'\033[36m'
    reset   $'\033[0m'
)

# Platform-to-asset-name mapping (zsh associative array)
typeset -A platform_assets
platform_assets=(
    darwin  "nvim-macos-x86_64.tar.gz"
    linux   "nvim-linux64.tar.gz"
)

# Utility functions using zsh features
print_status() {
    print "${colors[blue]}[INFO]${colors[reset]} $1"
}

print_success() {
    print "${colors[green]}[SUCCESS]${colors[reset]} $1"
}

print_error() {
    print "${colors[red]}[ERROR]${colors[reset]} $1" >&2
}

print_warning() {
    print "${colors[yellow]}[WARNING]${colors[reset]} $1"
}

print_question() {
    print "${colors[cyan]}[QUESTION]${colors[reset]} $1"
}

# Cleanup function using zsh array manipulation
cleanup() {
    local temp_files=($temp_dir/*(N))  # N flag for NULL_GLOB
    if (( ${#temp_files[@]} > 0 )); then
        print_status "Cleaning up temporary files..."
        rm -rf $temp_dir
    fi
}

# Trap cleanup on exit
trap cleanup EXIT INT TERM

# Ask user for confirmation
ask_confirmation() {
    local question=$1
    local default=${2:-"n"}
    
    local prompt
    if [[ $default == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    print_question "$question $prompt"
    read -r response
    
    # Handle empty response (use default)
    if [[ -z $response ]]; then
        response=$default
    fi
    
    # Normalize response
    response=${response:l}  # Convert to lowercase using zsh parameter expansion
    
    [[ $response == "y" || $response == "yes" ]]
}

# Detect shell configuration file
detect_shell_config() {
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.zprofile" 
        "$HOME/.profile"
    )
    
    # Check if any config file exists, prefer .zshrc for zsh
    for config_file in $config_files; do
        if [[ -f $config_file ]]; then
            echo $config_file
            return 0
        fi
    done
    
    # Default to .zshrc if none exist
    echo "$HOME/.zshrc"
}

# Add to PATH in shell configuration
add_to_path() {
    local nvim_bin_dir="$1"
    local config_file=$(detect_shell_config)
    
    print_status "Adding Neovim to PATH in $config_file"
    
    # Check if PATH export already exists
    local path_line="export PATH=\"\$HOME/.bin/nvim/bin:\$PATH\""
    local alt_path_line="export PATH=\"$nvim_bin_dir:\$PATH\""
    
    # Create config file if it doesn't exist
    if [[ ! -f $config_file ]]; then
        print_status "Creating $config_file"
        touch $config_file
    fi
    
    # Check if PATH is already configured (multiple possible formats)
    if grep -q "\.bin/nvim/bin" $config_file 2>/dev/null; then
        print_warning "Neovim PATH configuration already exists in $config_file"
        return 0
    fi
    
    # Add PATH export to config file
    print_status "Adding PATH configuration..."
    {
        echo ""
        echo "# Added by neovim-nightly installer"
        echo $path_line
    } >> $config_file
    
    print_success "Added Neovim to PATH in $config_file"
    print_success "Restart your terminal or run: ${colors[green]}source $config_file${colors[reset]}"
    
    return 0
}

# Get the latest nightly release download URL
get_nightly_download_url() {
    local platform=$1
    local asset_name=${platform_assets[$platform]}
    
    print_status "Fetching latest nightly release information..." >&2
    
    # First try the direct nightly URL
    local base_url="https://github.com/neovim/neovim/releases/download/nightly"
    local direct_url="${base_url}/${asset_name}"
    
    # Test if the direct URL works
    if curl -fsSL --head $direct_url >/dev/null 2>&1; then
        print_status "Found nightly release at: $direct_url" >&2
        echo $direct_url
        return 0
    fi
    
    print_status "Direct nightly URL not available, checking GitHub API..." >&2
    
    # Try to get the latest nightly release from GitHub API
    local api_response
    api_response=$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases" 2>/dev/null) || {
        print_error "Failed to fetch release information from GitHub API"
        return 1
    }
    
    # Parse the JSON to find nightly release (using basic grep/sed since jq might not be available)
    local download_url
    download_url=$(echo $api_response | grep -o "\"browser_download_url\":[[:space:]]*\"[^\"]*${asset_name}\"" | head -1 | sed 's/.*"browser_download_url":[[:space:]]*"\([^"]*\)".*/\1/')
    
    if [[ -z $download_url ]]; then
        print_error "Could not find download URL for $asset_name"
        print_error "Available assets might have changed. Please check:"
        print_error "https://github.com/neovim/neovim/releases/tag/nightly"
        return 1
    fi
    
    print_status "Found download URL via API: $download_url" >&2
    echo $download_url
}

# Check if we're on Apple Silicon Mac
detect_mac_architecture() {
    if [[ $OSTYPE == darwin* ]]; then
        local arch=$(uname -m)
        case $arch in
            arm64)
                echo "nvim-macos-arm64.tar.gz"
                ;;
            x86_64)
                echo "nvim-macos-x86_64.tar.gz"
                ;;
            *)
                print_warning "Unknown Mac architecture: $arch, defaulting to x86_64" >&2
                echo "nvim-macos-x86_64.tar.gz"
                ;;
        esac
    fi
}

# Main installation function
install_neovim_nightly() {
    # Detect platform using zsh's OSTYPE
    local platform
    case $OSTYPE in
        darwin*)
            platform="darwin"
            # Update the asset name based on architecture
            platform_assets[darwin]=$(detect_mac_architecture)
            ;;
        linux*)
            platform="linux"
            ;;
        *)
            print_error "Unsupported platform: $OSTYPE"
            print_error "This script supports macOS (darwin) and Linux only"
            return 1
            ;;
    esac

    print_status "Detected platform: $platform"
    print_status "Asset name: ${platform_assets[$platform]}"

    # Get download URL
    local download_url
    download_url=$(get_nightly_download_url $platform) || return 1

    print_status "Using download URL: $download_url"

    # Create installation directory with zsh parameter expansion
    local install_dir="${HOME}/.bin"
    local nvim_dir="${install_dir}/nvim"
    local nvim_bin_dir="${nvim_dir}/bin"
    
    # Create directories using zsh's mkdir with parameter expansion
    mkdir -p $install_dir

    # Create temporary directory
    temp_dir=$(mktemp -d -t nvim-install-XXXXXX)
    print_status "Using temporary directory: $temp_dir"

    # Download neovim nightly
    local archive_name="nvim-nightly.tar.gz"
    local archive_path="${temp_dir}/${archive_name}"
    
    print_status "Downloading Neovim nightly..."
    if ! curl -fsSL -o $archive_path "$download_url"; then
        print_error "Failed to download Neovim from $download_url"
        return 1
    fi

    print_success "Download completed"

    # Extract archive
    print_status "Extracting archive..."
    if ! tar -xzf $archive_path -C $temp_dir; then
        print_error "Failed to extract archive"
        return 1
    fi

    # Find extracted directory using zsh globbing
    local extracted_dirs=($temp_dir/nvim-*(N))
    if (( ${#extracted_dirs[@]} == 0 )); then
        print_error "No extracted nvim directory found"
        print_status "Contents of temp directory:"
        ls -la $temp_dir
        return 1
    fi

    local extracted_dir=${extracted_dirs[1]}
    print_status "Found extracted directory: $extracted_dir"

    # Remove existing installation if it exists
    if [[ -d $nvim_dir ]]; then
        print_warning "Removing existing Neovim installation at $nvim_dir"
        rm -rf $nvim_dir
    fi

    # Move extracted directory to installation location
    print_status "Installing to $nvim_dir..."
    if ! mv $extracted_dir $nvim_dir; then
        print_error "Failed to move Neovim to installation directory"
        return 1
    fi

    # Verify binary exists
    local nvim_binary="${nvim_bin_dir}/nvim"
    
    if [[ -f $nvim_binary ]]; then
        chmod +x $nvim_binary
        
        print_success "Neovim nightly installed successfully!"
        print_success "Binary location: $nvim_binary"
        
        # Verify installation
        if $nvim_binary --version >/dev/null 2>&1; then
            local version_info=$($nvim_binary --version | head -1)
            print_success "Installation verified: $version_info"
        else
            print_error "Installation verification failed"
            return 1
        fi
        
        # Handle PATH configuration
        if [[ ":$PATH:" != *":${nvim_bin_dir}:"* ]]; then
            print_warning "Neovim is not in your PATH"
            
            show_manual_path_instructions $nvim_bin_dir
        else
            print_success "Neovim is already in your PATH"
        fi
        
    else
        print_error "Neovim binary not found in extracted archive"
        print_status "Contents of extracted directory:"
        find $nvim_dir -type f -name "*nvim*" 2>/dev/null || true
        return 1
    fi
}

# Show manual PATH instructions
show_manual_path_instructions() {
    local nvim_bin_dir=$1
    local config_file=$(detect_shell_config)
    
    print_status "To add Neovim to your PATH manually, add this line to $config_file:"
    print "    ${colors[green]}export PATH=\"\$HOME/.bin/nvim/bin:\$PATH\"${colors[reset]}"
    print_status "Then restart your terminal or run: ${colors[green]}source $config_file${colors[reset]}"
}

# Check dependencies using zsh's whence
check_dependencies() {
    local deps=(curl tar)
    local missing_deps=()
    
    for dep in $deps; do
        if ! whence $dep >/dev/null 2>&1; then
            missing_deps+=($dep)
        fi
    done
    
    if (( ${#missing_deps[@]} > 0 )); then
        print_error "Missing dependencies: ${(j:, :)missing_deps}"
        print_error "Please install the missing dependencies and try again"
        return 1
    fi
}

# Main execution
main() {
    print_status "Starting Neovim Nightly installation..."
    
    # Check dependencies
    check_dependencies || return 1
    
    # Install Neovim
    install_neovim_nightly || return 1
    
    print_success "Installation completed successfully!"
    print_status "Run ${colors[magenta]}nvim${colors[reset]} to start Neovim (after adding to PATH or restarting terminal)"
}

# Run main function if script is executed directly
if [[ ${(%):-%x} == ${0} ]]; then
    main "$@"
fi
