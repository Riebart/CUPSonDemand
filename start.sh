#!/bin/bash

function wait_for_idle {
    echo "Waiting for '$1' to become idle"
    while [ true ]
    do
        lpstat -p "$1"
        lpstat -p "$1" | grep idle && break
        sleep 5
    done
    echo "'$1' is now idle"
}

mkdir -p /etc/cups

if [ ! -f /etc/cups/first_run ]
then
    echo "Running first-time config population"
    if [ -f /etc/cups/cupsd.conf ]
    then
        cp /etc/cups/cupsd.conf /etc/cups.orig/cupsd.conf
    fi

    cp -ar /etc/cups.orig/* /etc/cups/
    touch /etc/cups/first_run
fi

service cups start

while ! service cups status
do
    sleep 1
done

while ! tail /var/log/cups/*
do
    service cups status
    sleep 5
done

sleep 5

if [ -e /input ]
then
    printer_name=$(lpstat -p | grep "^printer" | sed 's/^printer \(.*\) is idle.*/\1/' | head -n1)
    for f in /input/*
    do
        echo "Sending print job: '$f' to printer '$printer_name'"
        lp -d "$printer_name" "$f"
        wait_for_idle "$printer_name"
    done
else
    tail -f /var/log/cups/*
fi
