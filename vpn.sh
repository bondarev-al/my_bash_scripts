#!/bin/bash

# скрипт обертка для работы с openvpn3

PROGRAM_NAME=$( basename $0 )

case "$1" in
    start|s|-s) echo start 
        ;;
    end|stop|e|-e) echo stop
        ;;
    *) echo "$PROGRAM_NAME: Invalid parameters." >&2 
        exit 1 ;;
esac

