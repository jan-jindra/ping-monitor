#!/bin/bash
#
# script moniters hosts; project results to html file(s)

version=2023.01.001

#variables
data=/root/test.csv #"database" 
htmlFinal=/var/www/localhost/htdocs/index.html #final html file
lastest=/root/lastest.txt # log of lastest changes

#web colours
green='#12d32c'
red='#d40e15'

#check envi
if [ ! -f $data ];then
    echo "No data loaded - exiting..."
    exit 1
fi

if [ -f $data.tmp ];then rm $data.tmp;fi
if [ -f $htmlFinal.tmp ];then rm $htmlFinal.tmp;fi
if [ ! -d /var/www/localhost/htdocs/hosts ];then mkdir -p /var/www/localhost/htdocs/hosts;fi
if [ ! -f $lastest ];then touch $lastest;fi

# reload data
OLDIFS=$IFS
IFS=';'
while read "group" "host" "alias" "lastStatus" "lastChange"
    do
    if [ ! -f /var/www/localhost/htdocs/hosts/$host.html ];then touch /var/www/localhost/htdocs/hosts/$host.html;fi
    now=$(date "+%d.%m.%C%y %H:%M:%S")
    newStatus=OFF
    echo -n "Testing $host...   "
    ping -c 1 $host >/dev/null && newStatus=OK
    echo $newStatus
    
    if [ -z $alias ];then
        resovledAlias=""
    else
        resovledAlias="($alias)"
    fi

    if [ ! "$newStatus" = "$lastStatus" ];then
        echo "Status of host $host has chaged from $lastStatus to $newStatus on $now."
        echo "$group;$host;$alias;$newStatus;$now" >> $data.tmp
        echo "$now : Status changed to $newStatus<br>" >> /var/www/localhost/htdocs/hosts/$host.html
        echo "$now : $host $resovledAlias - Status changed to $newStatus<br>" >> $lastest 

    else
        echo "$group;$host;$alias;$lastStatus;$lastChange" >> $data.tmp
    fi
done < $data
IFS=$OLDIFS
mv $data.tmp $data

# generate html
echo "
<!DOCTYPE html PUBLIC \`\"-//W3C//DTD XHTML 1.0 Strict//EN\`\"  \`\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\`\">
<html xmlns=\`\"http://www.w3.org/1999/xhtml\`\">
<head>
<p style='text-align:right'><b>$now</b></p>
<p style='text-align:right'><b>$version</b></p>
</head>
<style>
       body {
         margin: 0;
         font-family: Arial, Helvetica, sans-serif;
       }

       .topnav {
         overflow: hidden;
         background-color: #0f263e;
       }

       .topnav a {
         float: left;
         color: #f2f2f2;
         text-align: center;
         padding: 14px 16px;
         text-decoration: none;
         font-size: 17px;
       }

       .topnav a:hover {
         background-color: #7a8087;
         color: black;
       }
</style>
</head>
<body>
<style>

           body {
                  background-color: #3d3d3d;
                  color: #D3D3D3;
                  font-family: Tahoma, Arial;
                  font-size: 13px;
           }
           h1 {
                  font-size: 18px;
           }
           table, tr, td, th {
                  padding: 0;
                  margin: 0;
                  border-collapse: collapse;
           }
           table {
                  margin: auto;
                  width: 60%;
                  text-align: center;
           }
           td, th {
                  padding: 5px;
                  border: 1px solid #b9bbbd;
           }

           th {
                  padding: 10px 5px;
                  color: white;
                  background-color: #2d2e2e;
                  border-color: #b9bbbd;
           }
           tr:nth-child(even),
           tr:nth-child(even) td {
                  background-color: #787d80;
           }
           tr:nth-child(odd),
           tr:nth-child(odd) td {
                  background-color: #5c5e61;
           }
</style>

<h1 style='text-align:center;color:white;font-size:24px'><b>Ping monitor</b></h1><p></p>
<p></p>
<table>
    <colgroup><col/><col/><col/><col/><col/><col/></colgroup>
    <tr><th style='text-align:left'>Group</th><th style='text-align:left'>host (alias)</th><th>Last state</th><th>Last change</th></tr>
" > $htmlFinal.tmp

# hosts
OLDIFS=$IFS
IFS=';'
while read "group" "host" "alias" "lastStatus" "lastChange"
    do
<<output
    echo "============================="
    echo "Host        : $host"
    echo "Alias       : $alias"
    echo "Group       : $group"
    echo "Last Status : $lastStatus"
    echo "Last Change : $lastChange"
    echo 
output
    if [ -z $alias ];then
        resovledAlias=""
    else
        resovledAlias="($alias)"
    fi


    if [ "$lastStatus" = "OK" ];then 
        
        echo "<tr><td style='text-align:left'>$group</td><td style='text-align:left'><a href="/hosts/$host.html">$host $resovledAlias</a></td><td style='color:$green'>$lastStatus</td><td>$lastChange</td></tr>" >> $htmlFinal.tmp
        
        
    else
        echo "<tr><td style='text-align:left;color:$red'>$group</td><td style='text-align:left;color:$red'><a href="/hosts/$host.html">$host $resovledAlias</a></td><td style='color:$red'>$lastStatus</td><td style='color:$red'>$lastChange</td></tr>" >> $htmlFinal.tmp
    fi
done < $data
IFS=$OLDIFS
lastestLogs=$(tail -n 50 $lastest | tac )
echo "
</table>
<br>
<table>
<colgroup><col/><col/></colgroup>
    <tr><td style='color:white;text-align:left; width: 10%;color: black;background-color:white;font-size: 16px'><b>Lastest logs:</b></td></tr>
    <tr><td style='color:white;text-align:left; width: 10%;color: black;background-color:white;font-size: 11px'>$lastestLogs</td></tr>
</table>
</body></html>" >> $htmlFinal.tmp
mv $htmlFinal.tmp $htmlFinal
exit