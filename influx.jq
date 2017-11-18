#!/usr/bin/env jq -f

def to_influx:
    . as $i |
    $i | keys |
    reduce .[] as $item (
        [];
        . = . +[$item + "=" + $i[$item]]
    ) |
    join(",") |
    tostring
;

def select_keys(k):
    . as $i | $i | keys | map(select([.] | inside(k))) | reduce .[] as $item({};.[$item] = $i[$item])
;

def status_log:
    .[] |
    [(select_keys(["priority", "type"]) | to_influx), (select_keys(["event"]) | to_influx)]
        as
     [$tags, $values] |
     "status_log," + $tags + " " + $values
;

def usinfo:
     .[] |
     [(select_keys(["portId"]) | to_influx), (select_keys(["channelId","frequency","bandwidth","signalStrength"]) | to_influx)]
        as
     [$tags, $values] |
     "usinfo," + $tags + " " + $values
;

def dsinfo:
     .[] |
     [(select_keys(["portId"]) | to_influx), (select_keys(["channelId","frequency","signalStrength", "snr"]) | to_influx)]
        as
     [$tags, $values] |
     "dsinfo," + $tags + " " + $values
;
