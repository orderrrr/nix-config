set -g _rsh_host ""

function rsh
    set -l use_sudo ""
    set -l args $argv

    if test "$argv[1]" = "sudo"
        set use_sudo "sudo"
        set args $argv[2..-1]
    end

    switch $args[1]
        case activate
            set -g _rsh_host $args[2]
            echo "rsh target: $_rsh_host"
        case deactivate
            set -g _rsh_host ""
            echo "rsh target cleared"
        case tail
            test -z "$_rsh_host" && echo "no rsh target, run: rsh activate <host>" && return 1
            set -l comp $args[2]
            set -l app $args[3]
            ssh $_rsh_host -t $use_sudo tail -f /var/log/vsuite/$comp/$app/$comp-$app-human.log
        case app
            test -z "$_rsh_host" && echo "no rsh target" && return 1
            set -l comp $args[2]
            set -l app $args[3]
            ssh $_rsh_host -t $use_sudo vim /srv/vsuite/$comp/$app/etc/app.properties
        case application
            test -z "$_rsh_host" && echo "no rsh target" && return 1
            set -l comp $args[2]
            set -l app $args[3]
            ssh $_rsh_host -t $use_sudo vim /srv/vsuite/$comp/$app/etc/application.properties
        case logback
            test -z "$_rsh_host" && echo "no rsh target" && return 1
            set -l comp $args[2]
            set -l app $args[3]
            ssh $_rsh_host -t $use_sudo vim /srv/vsuite/$comp/$app/etc/logback.xml
        case wrapper
            test -z "$_rsh_host" && echo "no rsh target" && return 1
            set -l comp $args[2]
            set -l app $args[3]
            ssh $_rsh_host -t $use_sudo vim /srv/vsuite/$comp/$app/etc/wrapper.conf
        case ""
            if test -n "$_rsh_host"
                echo "active: $_rsh_host"
            else
                echo "no rsh target"
            end
        case '*'
            if test -n "$_rsh_host"
                ssh $_rsh_host -t $use_sudo $args
            else
                ssh $args
            end
    end
end
