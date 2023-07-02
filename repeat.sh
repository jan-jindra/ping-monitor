#!/bin/env bash

path=$(realpath $0)
scriptFolder=$(dirname $path)


while :
do
        clear
        now=$(date "+%d.%m.%C%y %H:%M:%S")
        echo
        echo "$now"
        bash $scriptFolder/run.sh
        echo "Pres CRTL+C to quit..."
        sleep 5
done
