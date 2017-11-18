#!/bin/bash

ROUTER_IP=${CGN_IP:-192.168.0.1}
USERNAME=${CGN_USERNAME:-cusadmin}
PASSWORD=${CGN_PASSWORD:-password}
FORMAT=${CGN_FORMAT:-csv}

COOKIE_FILE=cookie.txt
STATUS_LOG_FILE=status_log.csv
USINFO_FILE=usinfo.csv
DSINFO_FILE=dsinfo.csv

get_data() {
    page=$1

    login_status=`curl -s -c $COOKIE_FILE -d "user=$USERNAME&pws=$PASSWORD" http://$ROUTER_IP/goform/login`
    if [[ $login_status != success* ]]; then
        echo $login_status
        exit -1
    fi

    curl -s -b $COOKIE_FILE c $COOKIE_FILE http://$ROUTER_IP/data/$page.asp | jq -c -M -r "include \"./$FORMAT\"; $page"
    #curl -s -b $COOKIE_FILE http://$ROUTER_IP/data/$page.asp
    curl -s -c $COOKIE_FILE -b $COOKIE_FILE  http://$ROUTER_IP/goform/logout > /dev/null
}

status_log_headers='"timestamp","priority","type","event"'
usinfo_headers='"timestamp","channelId","portId","frequency","modulationType","signalStrength","snr","bandwidth"'
dsinfo_headers='"timestamp","channelId","portId","frequency","modulation","signalStrength","snr"'

case $1 in
"status_log")
    if [ ! -e $STATUS_LOG_FILE ]; then 
        echo $status_log_headers > $STATUS_LOG_FILE 
        get_data $1 >> $STATUS_LOG_FILE
    else
        last_date=`tail -1 $STATUS_LOG_FILE | awk -F ',' '{print $1}'`
        latest=`get_data $1`
        while read -r line; do
            d=`echo $line | awk -F ',' '{print $1}'`
            if [[ "$d" > "$last_date" ]]; then
                echo $line >> $STATUS_LOG_FILE
            fi
        done <<< "$latest"
    fi
;;
"usinfo")
    if [ ! -e $USINFO_FILE ]; then 
        echo $usinfo_headers > $USINFO_FILE
    fi
    get_data $1 >> $USINFO_FILE
;;
"dsinfo")
    if [ ! -e $DSINFO_FILE ]; then 
        echo $dsinfo_headers > $DSINFO_FILE
    fi
    get_data $1 >> $DSINFO_FILE
;;
*)
    echo "Unsupported command"
    exit -1
;;
esac