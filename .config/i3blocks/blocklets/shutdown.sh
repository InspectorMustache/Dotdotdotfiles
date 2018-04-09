#!/bin/bash
echo ''

sys_shutdown='systemctl poweroff'
sys_reboot='systemctl reboot'
sys_suspend='systemctl suspend'

function yad_sd {
    yad --button=' _Herunterfahren':21 \
        --button=' _Neustarten':22 \
        --button=' _Bereitschaft':23 \
        --button=gtk-close \
        --title=Herunterfahren \
        --text='System herunterfahren?\n' \
        --text-align=center

    case $? in
        21)
            eval $sys_shutdown
            ;;
        22)
            eval $sys_reboot
            ;;
        23)
            eval $sys_suspend
            ;;
    esac
}

function zenity_sd {
    zenity --question --text='System herunterfahren?'

    if [[ $? = 0 ]]; then
        eval $sys_shutdown
    fi
}

function nagbar_sd {
    i3-nagbar -m 'System herunterfahren?' \
              -t warning \
              --b '  Bereitschaft' "eval $sys_suspend" \
              --b '  Neustarten' "eval $sys_reboot" \
              --b '  Herunterfahren' "eval $sys_shutdown"
}

function dmenu_sd {
    options=$(printf '%s\n' '  Bereitschaft' '  Neustarten' '  Herunterfahren')
    response=$(echo -e "$options" | dmenu -p shutdown -i)

    case $response in
        '  Bereitschaft')
            eval $sys_shutdown
            ;;
        '  Neustarten')
            eval $sys_reboot
            ;;
        '  Herunterfahren')
            eval $sys_suspend
            ;;
    esac
}

if [[ $BLOCK_BUTTON = 1 ]]; then
    if which yad >/dev/null 2>&1; then
        yad_sd
    elif which zenity >/dev/null 2>&1; then
        zenity_sd
    elif which dmenu >/dev/null 2>&1; then
        dmenu_sd
    else
        nagbar_sd
    fi
fi
