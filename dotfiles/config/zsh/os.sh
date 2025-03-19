# opam configuration
test -r /Users/nmcintosh/.opam/opam-init/init.sh && . /Users/nmcintosh/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

alias lsblk='diskutil list'
alias python=/opt/homebrew/bin/python3
# alias nvim=/Users/nmcintosh/bin/nvim/bin/nvim

export PATH="/Users/nmcintosh/bin/nvim/bin:$PATH"

export PATH="/opt/homebrew/bin/sbcl:$PATH"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home
