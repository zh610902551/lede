#!/bin/sh
# wulishui 20200210 v1.2
# Author: wulishui <wulishui@gmail.com>

time=$(uci get cowbping.cowbping.time 2>/dev/null)
delaytime=$(uci get cowbping.cowbping.delaytime 2>/dev/null)
sleep "$delaytime"

while :
do

work_mode=$(uci get cowbping.cowbping.work_mode 2>/dev/null)
sum=$(uci get cowbping.cowbping.sum 2>/dev/null)
address=$(uci get cowbping.cowbping.address 2>/dev/null)
pkglost=$(uci get cowbping.cowbping.pkglost 2>/dev/null)

rm -f /tmp/log/cowbping 2>/dev/null
ping=`ping -c 1 "$address"|grep -o -E "([0-9]|[1-9][0-9]|100)"% | awk -F '%' '{print $1}'`
if [ "$ping" -ge "$pkglost" ]; then
 for i in $(seq 1 ${sum})
do
   ping=`ping -c 1 "$address"|grep -o -E "([0-9]|[1-9][0-9]|100)"% | awk -F '%' '{print $1}'`
   if [ "$ping" -ge "$pkglost" ]; then
     echo "1" >> /tmp/log/cowbping
   fi
  done
fi

sum0=`cat /tmp/log/cowbping 2>/dev/null|wc -l `
if [ "$sum0" -ge "$sum" ]; then

if [ "$work_mode" = "1" ]; then
reboot
fi

if [ "$work_mode" = "2" ]; then
killall -q pppd && pppd file /tmp/ppp/options.wan0 2>/dev/null
fi

if [ "$work_mode" = "3" ]; then
wifi down && wifi up 2>/dev/null
fi

if [ "$work_mode" = "4" ]; then
/etc/init.d/network restart
fi

if [ "$work_mode" = "5" ]; then
command=$(uci get cowbping.cowbping.command 2>/dev/null)
eval ${command}
fi

if [ "$work_mode" = "6" ]; then
Randommac=`dd if=/dev/urandom bs=1 count=32 2>/dev/null | md5sum | cut -b 0-12 | sed 's/\(..\)/\1:/g; s/.$//'`
uci set network.wwan.macaddr="$Randommac" 2>/dev/null
uci commit network
/etc/init.d/network restart
uci set wireless.@wifi-iface[-1].macaddr="$Randommac" 2>/dev/null
uci commit wireless
wifi down && wifi up 2>/dev/null
fi

fi

sleep "$time"
done

