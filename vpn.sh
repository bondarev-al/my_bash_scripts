#!/bin/bash

# скрипт обертка для работы с openvpn3

PROGRAM_NAME=$( basename $0 )

# создание в домашней директории папки с файлами настроек
settings_dir=$HOME/.vpn_bondarev-al
if [ ! -d "$settings_dir" ]; then 
    mkdir "$settings_dir"
    chmod 700 "$settings_dir"
fi 

vpn_file_pref='.vpn_'
last_connection_file='.last_connection'

case "$1" in
    start|s|-s) echo start 
	if [ "$2" ]; then
	    name=$2
	else
	    read name < ${settings_dir}/${last_connection_file}
	fi
        if [ -e "${settings_dir}/${vpn_file_pref}${name}" ]; then
            # читаем найстройки vpn из файла
            for i in config login password; do
                read $i
            done < ${settings_dir}/${vpn_file_pref}${name}
	    openvpn3 session-start --config "$config" <<- _EOF_
		$login
		$password
		_EOF_
            echo "$name" > ${settings_dir}/${last_connection_file}
	else
		echo "$PROGRAM_NAME: Error. Setting file '$name' don't exist." >&2
		exit 4

        fi
        ;;
    end|stop|e|-e) echo stop
        if [ -e "${settings_dir}/${last_connection_file}" ]; then
            # читаем найстройки vpn из файла
            read name < ${settings_dir}/${last_connection_file}
            read config < ${settings_dir}/${vpn_file_pref}${name}
	    openvpn3 session-manage --config "$config" --disconnect
	fi
        ;;
    new|n|-n) echo new
	# Ввод имени файла для настроек vpn    
        read -p "Enter name for vpn settings: " name 
	while [[ ! "$name" =~ ^[[:alnum:]_-]+$ ]]; do
		echo "$PROGRAM_NAME: Invalid name. Use [A-Za-z0-9_-]."
		read -p "Enter name for vpn settings: " name 
	done
	# Проверка есть ли такой файл, если есть, то уточняется нужно ли его перезаписывать
        if [ -e "${settings_dir}/${vpn_file_pref}${name}" ]; then
		read -p "$PROGRAM_NAME: Such filename exist. Do you want to overwrite it? [yes/no] "
		if [[ ! "$REPLY" =~ ^(yes|y)$ ]]; then
			echo "$PROGRAM_NAME: Error. Such filename exist." >&2
			exit 2
		fi
	fi
	# Ввод пути к файлу .ovpn
	read -p "Enter path to .ovpn file: " ovpn_file
	while [ ! -e "$ovpn_file" ]; do
		echo "$PROGRAM_NAME: '$ovpn_file' - such file don't exist."
		read -p "Enter path to .ovpn file: " ovpn_file
	done
	# Импорт настроек в openvpn3
	openvpn3 config-import --config "$ovpn_file" --name "$name" --persistent
	# Ввод логина и пароля для подключения
	read -p "Enter login for vpn: " login
	read -sp "Enter password for vpn: " password && echo ""
	# Запись настроек в файл
	echo "$name" > "${settings_dir}/${vpn_file_pref}${name}"
	echo "$login" >> "${settings_dir}/${vpn_file_pref}${name}"
	echo "$password" >> "${settings_dir}/${vpn_file_pref}${name}"
	chmod 600 "${settings_dir}/${vpn_file_pref}${name}"
        ;;
    delete|d|-d) echo delete
	search_mask="${settings_dir}/${vpn_file_pref}*"
	setting_array=( $( echo ${search_mask} )  )
	if [ "$setting_array" != "${search_mask}" ]; then
		i=0
		echo "Settings list:"
		for setting in ${setting_array[@]//"${settings_dir}/${vpn_file_pref}"}; do
			echo  "$(( i++ ))) $setting" 
		done
		read -p "Enter setting number for deletion: "
		if [[ $REPLY =~ ^[[:digit:]]+$  ]]; then
			if (( -1 < $REPLY && $REPLY < ${#setting_array[@]} )); then
				read config < "${setting_array[$REPLY]}"
				openvpn3 config-remove --config "$config" <<< "YES" > /dev/null
				rm "${setting_array[$REPLY]}"
				echo "File '${setting_array[$REPLY]}' deleted."
			else
				echo "$PROGRAM_NAME: Error. No such number." >&2
				exit 3
			fi
		else
			echo "$PROGRAM_NAME: Error. It's not a number." >&2
			exit 3
		fi
	else
	       	echo "You don't have setting file. You can create it use parameter new|-n|n."
	fi
	;;
    list|l|-l|settings) echo settings
        ;;
    help|-h|--help) echo help
        ;;
    menu|m|-m) echo menu
        ;;
    *) echo "$PROGRAM_NAME: Error. Invalid parameters." >&2 
        exit 1 ;;
esac

