#!/bin/bash
#
# script moniters hosts; project results to html file(s)

version=2023.01.001

#variables
data=/root/test.csv #"database" 
htmlFinal=/var/www/localhost/htdocs/index.html #final html file

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

# reload data
OLDIFS=$IFS
IFS=';'
while read "group" "host" "alias" "lastStatus" "lastChange"
    do
    if [ ! -f /var/www/localhost/htdocs/hosts/$host.html ];then touch /var/www/localhost/htdocs/hosts/$host.html;fi
    now=$(date "+%d.%m.%C%y %H:%M:%S")
    newStatus=OFF
    echo "Testing $host..."
    ping -c 1 $host >/dev/null && newStatus=OK
    if [ ! "$newStatus" = "$lastStatus" ];then
        echo "Status of host $host has chaged from $lastStatus to $newStatus on $now."
        echo "$group;$host;$alias;$newStatus;$now" >> $data.tmp
        echo "$now : Status changed to $newStatus<br>" >> /var/www/localhost/htdocs/hosts/$host.html
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
                  background-color: #1e3953;
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
                  border: 1px solid #20adf2;
           }

           th {
                  padding: 10px 5px;
                  color: white;
                  background-color: #0f263e;
                  border-color: #20adf2;
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
    <tr><th>Group</th><th>host (alias)</th><th>Last state</th><th>Last change</th></tr>
" > $htmlFinal.tmp
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
        
        echo "<tr><td>$group</td><td><a href="/hosts/$host.html">$host $resovledAlias</a></td><td style='color:$green'>$lastStatus</td><td>$lastChange</td></tr>" >> $htmlFinal.tmp
        
        
    else
        echo "<tr><td style='color:$red'>$group</td><td style='color:$red'><a href="/hosts/$host.html">$host $resovledAlias</a></td><td style='color:$red'>$lastStatus</td><td style='color:$red'>$lastChange</td></tr>" >> $htmlFinal.tmp
    fi
done < $data
IFS=$OLDIFS

echo "
</table>
</body></html>" >> $htmlFinal.tmp
mv $htmlFinal.tmp $htmlFinal
exit