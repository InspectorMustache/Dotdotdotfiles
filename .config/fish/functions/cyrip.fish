function cyrip -w cyanrip
    command -q cyanrip || return 1

    if not set -q CYANRIP_OFFSET
        echo "Environment variable CYANRIP_OFFSET not set. Run cynarip -f to find out your drive\'s offset and set the variable."
        return 1
    end

    set_color -o; echo "Running cyanrip with offset $CYANRIP_OFFSET."; set_color normal
    cyanrip -U -s "$CYANRIP_OFFSET" -E $argv 2>/dev/null

    if [ $status -eq 1 ]
        while true
            read -P "Enter desired release number from list above: " selection
            test "$status" -ne 0 && return 1
            string match -rq '^\d+$' -- "$selection" && break
        end
    end

    cyanrip -U -s "$CYANRIP_OFFSET" -E -R $selection $argv
end
