#
#
# script finds RouteBoards in the network

# variable - the need to move to file
mainRB=192.168.80.254  # IP of main RB, with neigbor is active
localFile=/root/rbs.txt #local whare newly discovered routerboards are stored
sshUser=jindra #ssh user for login to all routers. SSH keys required!
db=/root/rbs.csv #file containing all routerboards


# script
ssh $sshUser@$mainRB "ip neighbor/print" >$localFile
tail -n +3 "$localFile" > $localFile.tmp; mv $localFile.tmp $localFile

#check for new RouterBoards
if [! -f $db ];then touch $db
while read "line"
    do
    #echo $line
    address=$(echo $line | awk '{print $3}')
    mac=$(echo $line | awk '{print $4}')
    identity=$(echo $line | awk '{print $5}')
   

    if [ ! -z $identity ]; then
    echo "======================="
    echo "Routerboard : $identity"
    echo "IP          : $address"
    echo "MAC         : $mac"
    fi

    now=$(date "+%d.%m.%C%y %H:%M:%S")
    newStatus=OFF
    echo -n "Testing $host...   "
    ping -c 1 $host >/dev/null && newStatus=OK
    echo $newStatus
    
done < $localFile