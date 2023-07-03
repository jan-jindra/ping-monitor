#!/bin/env bash

if [ ! -f /data/data.csv ];then
    echo "Hello and welcome. This is your first run of this container. Please goto <b> https://ip-of-this-site:4200/ </b> and configure your clients." > /var/www/html/index.html
    service apache2 start
    service shellinabox start
    
    un=ping-monitor
    pw=123456
    adduser --disabled-password --gecos "" $un
    echo "$un:$pw" | chpasswd
    
    mkdir /data
    chmod 777 /data
    mv /root/menu.sh /data/menu.sh
    chmod +x /data/menu.sh
    echo '/data/menu.sh' >>/home/$un/.bashrc
fi


while :
do
        bash /root/run.sh      
        sleep 5
done
