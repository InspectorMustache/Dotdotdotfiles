#!/bin/bash

function print_time_info {
    case ${_BLOCK_STATE} in
        time)
            current_time=$(date +%H:%M )
            ;;
        date)
            current_time=$(date +%a,\ %e.%m.%Y)
            ;;
    esac
    echo "{\"full_text\" : \"$current_time\", \"_BLOCK_STATE\" : \"$_BLOCK_STATE\"}"
}

function get_new_state {
    case ${_BLOCK_STATE} in
        time)
            echo date
            ;;
        date)
            echo time
            ;;
    esac
}

case ${BLOCK_BUTTON} in 
    3)
        notify-send --icon=none "$(date +%A,\ %d.%m.%Y)" "\n$(cal)"
        print_time_info
    ;;
    1)
        _BLOCK_STATE=$(get_new_state)
        print_time_info
    ;;
    *)
        print_time_info
    ;;
esac
