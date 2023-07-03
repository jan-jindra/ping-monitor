#!/bin/bash
#
# script creates simple menu for controling server side tasks

# trap ctrl-c and call ctrl_c() so user cannot ctrl_c from script to shell
trap ctrl_c INT
function ctrl_c() {
        pkill -KILL -u ping-monitor
}

clear
while true
do
    echo
    echo "        Ping monitor"
    echo "============================"
    echo
    echo "MENU:
        1) Add new client
        2) Delete client
        3) Change password
        4) Terminal
        5) Exit
    "
    read -p 'You choice: ' choice

    case $choice in

        1)
        echo
        echo "You choose to add new client."
        read -p 'IP/DNS name of client : ' clientIP
        read -p 'Group of client       : ' clientGroup
        read -p 'alias of client       : ' clientAlias
       
        echo "Adding client client $clientAlias with IP $clientIP from $clientGroup"
        echo "$clientGroup;$clientIP;$clientAlias" >>/data/data.csv
        echo "done"
    
        ;;
        2)
        echo
        echo "You choose to delete client."
        read -p 'Delete client : ' clientDel
        grep -v "$clientDel" /data/data.csv > tmpfile && mv tmpfile /data/data.csv
        ;;

        3)
        echo
        echo "You choose to change password."
        passwd
        ;;

        4)
        echo "Going to terminal"
        exitStategy="terminal"
        break
        ;;

        5)
        echo "exiting"
        exitStrategy="logout"
        break
        ;;

    esac
    echo
    echo
done

echo
echo
if [ "$exitStrategy" = "logout" ];then
        clear
        pkill -KILL -u ping-monitor
fi
exit