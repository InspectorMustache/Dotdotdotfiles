function __vterm_setup

    functions --copy fish_prompt vterm_old_fish_prompt
    
    function fish_vi_cursor
        return
    end

    function vterm_printf
        printf "\e]%s\e\\" "$argv"
    end

    function vterm_prompt_end;
        vterm_printf '51;A'(whoami)'@'(hostname)':'(pwd)
    end

    function vterm_cmd --description 'Run an Emacs command among the ones been defined in vterm-eval-cmds.'
        set -l vterm_elisp ()
        for arg in $argv
            set -a vterm_elisp (printf '"%s" ' (string replace -a -r '([\\\\"])' '\\\\\\\\$1' $arg))
        end
        vterm_printf '51;E'(string join '' $vterm_elisp)
    end

    function find_file
        set -q argv[1]; or set argv[1] "."
        vterm_cmd find-file (realpath "$argv")
    end

    function say
        vterm_cmd message "%s" "$argv"
    end

    function fish_prompt --description 'Write out the prompt; do not replace this. Instead, put this at end of your file.'
        # Remove the trailing newline from the original prompt. This is done
        # using the string builtin from fish, but to make sure any escape codes
        # are correctly interpreted, use %b for printf.
        printf "%b" (string join "\n" (vterm_old_fish_prompt))
        vterm_prompt_end
    end

end
