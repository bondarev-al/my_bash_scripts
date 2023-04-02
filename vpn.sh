#!/bin/bash

# скрипт обертка для работы с openvpn3

PROGRAM_NAME=$( basename $0 )

# создание в домашней директории папки с файлами настроек
settings_dir=$HOME/.vpn_bondarev-al
if [ ! -d "$settings_dir" ]; then 
    mkdir "$settings_dir"
    chmod 700 "$settings_dir"
fi 

case "$1" in
    start|s|-s) echo start 
        ;;
    end|stop|e|-e) echo stop
        ;;
    new|n|-n) echo new
        ;;
    list|l|-l|settings) echo settings
        ;;
    help|-h|--help) echo help
        ;;
    menu|m|-m) echo menu
        ;;
    *) echo "$PROGRAM_NAME: Invalid parameters." >&2 
        exit 1 ;;
esac

