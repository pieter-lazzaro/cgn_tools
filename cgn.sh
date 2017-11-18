#!/bin/bash

ROUTER_IP=${CGN_IP:-192.168.0.1}
USERNAME=${CGN_USERNAME:-cusadmin}
PASSWORD=${CGN_PASSWORD:-password}
FORMAT=${CGN_FORMAT:-csv}

COOKIE_FILE=cookie.txt

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

get_data $1
