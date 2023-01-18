#!/bin/bash

while :
do
        now=$(date "+%d.%m.%C%y %H:%M:%S")
        echo
        echo "$now"
        bash /root/run.sh
        sleep 5
done


