function extract --description "Extract archives: extract <file>"
    set -l file $argv[1]
    if test -z "$file"
        echo "Usage: extract <archive>"
        return 1
    end
    if not test -f "$file"
        echo "Not a file: $file"
        return 1
    end
    switch $file
        case '*.tar.bz2' '*.tbz2'
            tar xjf "$file"
        case '*.tar.gz' '*.tgz'
            tar xzf "$file"
        case '*.tar.xz' '*.txz'
            tar xJf "$file"
        case '*.tar.zst' '*.tzst'
            tar --use-compress-program=unzstd -xvf "$file"
        case '*.tar'
            tar xf "$file"
        case '*.zip'
            unzip -q "$file"
        case '*.rar'
            unrar x "$file"
        case '*.7z'
            7z x "$file"
        case '*'
            echo "Don't know how to extract: $file"
            return 1
    end
end

# compress: create archives by extension
# Usage:
#   compress [-f] [archive.{tar.gz|tar.zst|tar.xz|tar.bz2|tar|zip|7z}] <paths...>
# Examples:
#   compress src dist            # -> src.tar.gz (includes src and dist)
#   compress site.tgz public     # -> site.tgz
#   compress -f app.tar.zst app  # force overwrite
function compress --description "Create archives by extension"
    set -l force 0

    # Parse flags
    while test (count $argv) -gt 0
        switch $argv[1]
            case -f --force
                set force 1
                set -e argv[1]
            case --
                set -e argv[1]
                break
            case '-*'
                echo "Unknown option: $argv[1]"
                echo "Usage: compress [-f] [archive.ext] <paths...>"
                return 2
            case '*'
                break
        end
    end

    if test (count $argv) -lt 1
        echo "Usage: compress [-f] [archive.{tar.gz|tar.zst|tar.xz|tar.bz2|tar|zip|7z}] <paths...>"
        return 1
    end

    # Determine destination and paths
    set -l dest
    set -l paths

    switch $argv[1]
        case '*.tar.gz' '*.tgz' '*.tar.xz' '*.txz' '*.tar.bz2' '*.tbz2' '*.tar.zst' '*.tzst' '*.tar' '*.zip' '*.7z'
            if test (count $argv) -lt 2
                echo "No input paths provided."
                return 1
            end
            set dest $argv[1]
            set paths $argv[2..-1]
        case '*'
            # Default to <first_path>.tar.gz
            set paths $argv
            set -l base (basename $paths[1])
            set dest "$base.tar.gz"
    end

    # Validate inputs
    for p in $paths
        if not test -e "$p"
            echo "Not found: $p"
            return 1
        end
    end

    if test -e "$dest"; and test $force -eq 0
        echo "Refusing to overwrite: $dest (use -f to force)"
        return 1
    end

    # Create archive based on extension
    switch $dest
        case '*.tar.gz' '*.tgz'
            if type -q pigz
                tar --exclude-vcs --use-compress-program=pigz -cf "$dest" $paths
            else
                tar -czf "$dest" --exclude-vcs $paths
            end
        case '*.tar.xz' '*.txz'
            if type -q pxz
                tar --exclude-vcs --use-compress-program=pxz -cf "$dest" $paths
            else if type -q xz
                tar -cJf "$dest" --exclude-vcs $paths
            else
                echo "xz not found; install xz or choose a different format."
                return 1
            end
        case '*.tar.bz2' '*.tbz2'
            tar -cjf "$dest" --exclude-vcs $paths
        case '*.tar.zst' '*.tzst'
            if type -q zstd
                tar --exclude-vcs --use-compress-program='zstd -T0 -19' -cf "$dest" $paths
            else
                echo "zstd not found; install zstd or choose a different format."
                return 1
            end
        case '*.tar'
            tar -cf "$dest" --exclude-vcs $paths
        case '*.zip'
            if not type -q zip
                echo "zip not found; install zip or choose a different format."
                return 1
            end
            zip -r -9 "$dest" $paths
        case '*.7z'
            if not type -q 7z
                echo "7z not found; install p7zip/7z or choose a different format."
                return 1
            end
            7z a -mx=9 "$dest" $paths
        case '*'
            echo "Unsupported archive type: $dest"
            return 1
    end

    echo "Created: $dest"
end
