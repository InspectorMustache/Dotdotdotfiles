function fish_user_key_bindings
    fish_hybrid_key_bindings
    fzf_key_bindings
    
    # additional bindings that base fzf search in $MEDIA
    bind -M insert \eC 'commandline $MEDIA; and fzf-cd-widget'
    bind -M insert \et 'commandline -a $MEDIA; and fzf-file-widget'

    # history and completion bindings
    bind -M insert \ek up-or-search
    bind -M insert \ej down-or-search
    bind -M insert \e\l forward-bigword
    bind -M insert \e\x20 accept-autosuggestion

    # iso friendly Emacs keys
    bind -M insert \cf forward-word
    bind -M insert \cb backward-word

    # prepend/append commands by keypress
    bind -M insert \ep __fish_plz_bind
    bind -M insert \ea __fish_away_bind
    bind -M insert \cG __fish_lass_bind

    # better line editing
    bind -M insert \cQ edit_command_buffer
    bind \cQ edit_command_buffer

    # file selection with vifm
    bind -M insert \e\u00b4 __fish_vifm_bind

    # keybindings for path navigation
    bind -M insert \eH 'prevd; commandline -f repaint'
    bind -M insert \eL 'nextd; commandline -f repaint'
    bind -M insert \eK '__fish_cd_navigation up; commandline -f repaint'
    bind -M insert \eJ '__fish_cd_navigation down; commandline -f repaint'

    # create a directory from the current token
    bind -M insert \eo 'mkdir -p (commandline -t)'

    # update history but keep commandline
    bind -M insert \e\cH 'history merge'

    # clear terminal screen
    bind -M insert \e\cL 'cls; commandline -f repaint'

    # toggle shadow mode
    bind -M insert \e\? 'if set -q fish_private_mode; exec fish; else; exec fish --private; end'
end
