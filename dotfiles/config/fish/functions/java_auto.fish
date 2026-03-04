# Automatically set JAVA_HOME based on pom.xml java.version when changing directories.
# Fires on every directory change via fish's variable-watch on PWD.

function __java_auto_detect --on-variable PWD
    # Only act if pom.xml exists in the new directory
    test -f pom.xml; or return

    set -l jver (string match -r '<java\.version>([^<]+)</java\.version>' < pom.xml)[2]
    test -n "$jver"; or return

    set -l jhome
    switch $jver
        case '1.8' '8'
            set jhome /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
        case '17'
            set jhome /Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
        case '21'
            set jhome /Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
        case '24'
            set jhome /Library/Java/JavaVirtualMachines/zulu-24.jdk/Contents/Home
        case '*'
            echo "java_auto: unknown java.version '$jver' in pom.xml"
            return 1
    end

    if test -d "$jhome"
        set -gx JAVA_HOME $jhome
        fish_add_path --move --path "$jhome/bin"
        echo "java_auto: JAVA_HOME → $jhome (java.version=$jver)"
    else
        echo "java_auto: JDK not found at $jhome"
    end
end
