#!/bin/bash

cat /dev/null > cameras-datetime.txt
echo "ip,date,time,timezone,current_date,current_time" > cameras-datetime.csv

function main {
        while read camera; do
                ping -c 3 $camera >/dev/null 2>&1
                if [ $? -ne 0 ]; then
                        echo "$camera NOT REACHABLE" >> cameras-datetime.txt
                        echo "$camera NOT REACHABLE"
                else
                        get_datetime
                fi
        done < cams.txt
}

function get_datetime {
        onvifdt=$(onvif-cli --user '' --password '' --host ''$camera'' --port 2000 --wsdl /etc/onvif/wsdl/ devicemgmt GetSystemDateAndTime | grep = | head -n 9)
        current_date=$(date +"%d/%m/%Y")
        current_time=$(date +"%H:%M:%S")
        camtz=$(echo "$onvifdt" | grep 'TZ' | sed 's/TZ = //' | sed 's/ //g')
        camhour=$(echo "$onvifdt" | grep 'Hour' | sed 's/Hour = //' | sed 's/ //g')
        camminute=$(echo "$onvifdt" | grep 'Minute' | sed 's/Minute = //' | sed 's/ //g')
        camsecond=$(echo "$onvifdt" | grep 'Second' | sed 's/Second = //' | sed 's/ //g')
        camyear=$(echo "$onvifdt" | grep 'Year' | sed 's/Year = //' | sed 's/ //g')
        cammonth=$(echo "$onvifdt" | grep 'Month' | sed 's/Month = //' | sed 's/ //g')
        camday=$(echo "$onvifdt" | grep 'Day' | sed 's/Day = //' | sed 's/ //g')
        camdt=$(echo "$camday/$cammonth/$camyear $camhour:$camminute:$camsecond $camtz")
        echo "$camera ($camdt)" >> cameras-datetime.txt
        echo "$camera,$camday/$cammonth/$camyear,$camhour:$camminute:$camsecond,$camtz,$current_date,$current_time" >> cameras-datetime.csv
        echo "$camera ($camdt)"
}

main