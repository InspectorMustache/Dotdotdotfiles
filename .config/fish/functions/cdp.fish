function cdp -d "Browse through the file system with fzf."
    if [ -d "$argv" ]
        cd "$argv"
    else if [ -n "$argv" ]
        echo "$argv is not a directory." >&2 && return 1
    end

    set orig_destination (pwd)
    true
    while true
        set files *
        printf "%s\n" $files .. | fzf --preview="echo -e \"\e[1;37m\"{}\"\e[0m\"; if [ -d {} ]; then ls {}; elif grep -qI '' {}; then head -n \$((\$FZF_PREVIEW_LINES - 1)) {}; else file {} | fold -s -w \$FZF_PREVIEW_COLUMNS; fi" \
            --bind="ctrl-c:execute(cd \"$orig_destination\")+abort" | read selection
        if [ -d "$selection" ]
            cd $selection
        else if [ -f "$selection" ]
            commandline " "(string escape $selection)
            commandline -C 0
            break
        else
            break
        end
    end
end
