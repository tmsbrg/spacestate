#!/bin/sh
# query space state from arduino door server and update it on site

# required packages: curl, iproute2, net-tools

# give ETH and PASS from environment variables. Ex:
# ETH=eth0 PASS=wowverygoodpassword spacestate.sh
if [ -z "$PASS" -o -z "$ETH" ]; then
    echo "ERROR! Missing PASS and/or ETH environment variables" 1>&2
    echo "Use PASS for spacestate web password" 1>&2
    echo "Use ETH for eth0 device name" 1>&2
    echo "Ex: ETH=eth0 PASS=verysecurepassword spacestate.sh" 1>&2
    exit 1
fi


# get an ip in same network as arduino door server
sudo ifconfig "$ETH" up
sudo ip address add 10.89.13.74/24 dev "$ETH"
sleep 5s

URL="https://frack.nl/spacestate/"
STATE=0
while true; do
    NEW_STATE=$(curl -sS http://10.89.13.233/ | grep -c 1)
    if [ $NEW_STATE -ne $STATE ]; then
        STATE=$NEW_STATE
        echo STATE CHANGED!!!! NEW STATE = "$NEW_STATE"
        curl -sS --data-urlencode pass="$PASS" --data-urlencode newstate="$STATE" "$URL" > /dev/null
    fi
    sleep 10s
done
