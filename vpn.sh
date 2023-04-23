#!/bin/bash

# скрипт обертка для работы с openvpn3

PROGRAM_NAME=$( basename $0 )

# создание в домашней директории папки с файлами настроек
settings_dir=$HOME/.vpn_bondarev-al
if [ ! -d "$settings_dir" ]; then 
    mkdir "$settings_dir"
    chmod 700 "$settings_dir"
fi 

vpn_file='bmstu'
vpn_file_pref='.vpn_'

case "$1" in
    start|s|-s) echo start 
        cd "$settings_dir"
        if [ -e "${vpn_file_pref}${vpn_file}" ]; then
            # читаем найстройки vpn из файла
            for i in config login password; do
                read $i
            done < ${vpn_file_pref}${vpn_file}
	    openvpn3 session-start --config "$config" <<- _EOF_
		$login
		$password
		_EOF_
        fi
        ;;
    end|stop|e|-e) echo stop
        cd "$settings_dir"
        if [ -e "${vpn_file_pref}${vpn_file}" ]; then
            # читаем найстройки vpn из файла
            read config < ${vpn_file_pref}${vpn_file}
	    openvpn3 session-manage --config "$config" --disconnect
	fi
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

