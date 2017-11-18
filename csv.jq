#!/usr/bin/env jq -f

def select_keys(k):
    . as $i | $i | keys | map(select([.] | inside(k))) | reduce .[] as $item({};.[$item] = $i[$item])
;

def status_log:
    .[] | [(.time|strptime("%m/%d/%Y %H:%M:%S")|strftime("%Y-%m-%dT%H:%M:%SZ")), .priority,.type,.event] | @csv
;

def usinfo:
     .[] | [(now|strftime("%Y-%m-%dT%H:%M:%SZ")),.channelId,.portId,.frequency,.modulationType,.signalStrength,.snr,.bandwidth]
;

def dsinfo:
     .[] | [(now|strftime("%Y-%m-%dT%H:%M:%SZ")),.channelId,.portId,.frequency,.modulation,.signalStrength,.snr] | @csv
;
