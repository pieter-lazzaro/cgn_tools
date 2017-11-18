#!/bin/bash

ROUTER_IP=${CGN_IP:-192.168.0.1}
USERNAME=${CGN_USERNAME:-cusadmin}
PASSWORD=${CGN_PASSWORD:-password}

COOKIE_FILE=cookie.txt

get_data() {
    page=$1

    curl -s -c $COOKIE_FILE -d "user=$USERNAME&pws=$PASSWORD" http://$ROUTER_IP/goform/login > /dev/null

    curl -s -b $COOKIE_FILE c $COOKIE_FILE http://$ROUTER_IP/data/$page.asp | jq -c -M -r "include \"./functions\"; $page"
    #curl -s -b $COOKIE_FILE http://$ROUTER_IP/data/$page.asp
    curl -s -c $COOKIE_FILE -b $COOKIE_FILE  http://$ROUTER_IP/goform/logout > /dev/null
}

get_data $1
