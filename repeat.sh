#!/bin/bash

while :
do
        clear
        now=$(date "+%d.%m.%C%y %H:%M:%S")
        echo
        echo "$now"
        bash /root/run.sh
        echo "Pres CRTL+C to quit..."
        sleep 5
done


