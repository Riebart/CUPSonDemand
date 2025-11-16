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

# Step 1: Get the IP address of the printer
printer_ip_address=$(
(
  seq 2 254 |
  while read p
  do
    nc -vnzw1 10.0.0.$p 80 2>&1 &
  done
) | grep succeeded | cut -d ' ' -f3 |
while read ip
do
  wget -qO- http://${ip} |
    grep -c "http-equiv=author .*Canon Inc." >/dev/null 2>&1 &&
    echo "$ip" &&
    break
done)

echo "Printer IP address identified as ${printer_ip_address}"

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

(
  grep -cir "$printer_ip_address" /etc/cups >/dev/null 2>&1 &&
  echo "Printer IP address present in configs"
) || (
  echo "Printer IP address not present in configs, swapping it"
  current_printer_ip=$(
    grep -ir ipp:// /etc/cups | cut -d ' ' -f2 | cut -d '/' -f3 | sort | uniq
  )
  find /etc/cups -type f | while read f; do sed -i "s|//${current_printer_ip}|//${printer_ip_address}|" "$f"; done
)

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
