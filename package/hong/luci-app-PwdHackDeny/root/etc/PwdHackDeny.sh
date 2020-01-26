#!/bin/bash
# wulishui 20200122 v2.2
# Author: wulishui <wulishui@gmail.com>

time=$(uci get PwdHackDeny.PwdHackDeny.time 2>/dev/null)
sum=$(uci get PwdHackDeny.PwdHackDeny.sum 2>/dev/null)
localIP=$(uci get network.lan.ipaddr|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){2}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}')

while :
do

log_size1=`du /tmp/PwdHackDeny/badip.log.ssh.tmp1|awk '{print $1}'` 2>/dev/null
if [ $log_size1 -gt 100 ]; then
 echo "" > /tmp/PwdHackDeny/badip.log.ssh.tmp1
fi
log_size1=`du /tmp/PwdHackDeny/badip.log.web.tmp1|awk '{print $1}'` 2>/dev/null
if [ $log_size1 -gt 100 ]; then
 echo "" > /tmp/PwdHackDeny/badip.log.web.tmp1
fi

cat /proc/net/arp |tail +2|sed 's/[ ][ ]*/ /g'|sed '/^ *$/d'|tr '[a-z]' '[A-Z]'|awk '{print $1" "$4}' > /tmp/PwdHackDeny/dhcp.leases
#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

logread|grep dropbear|grep "Bad password attempt" >> /tmp/PwdHackDeny/badip.log.ssh.tmp1
logread|grep uhttpd  |grep "failed login on"      >> /tmp/PwdHackDeny/badip.log.web.tmp1

cat /tmp/PwdHackDeny/badip.log.ssh.tmp1|sort -n|uniq -i|sed '/^ *$/d' > /tmp/badip.log.ssh.tmp2
cat /tmp/PwdHackDeny/badip.log.web.tmp1|sort -n|uniq -i|sed '/^ *$/d' > /tmp/badip.log.web.tmp2

cat /tmp/badip.log.ssh.tmp2 /tmp/PwdHackDeny/badip.log.ssh | sort | uniq -d > /tmp/badip.log.ssh.tmp3
cat /tmp/badip.log.ssh.tmp2 /tmp/badip.log.ssh.tmp3        | sort | uniq -u >> /tmp/PwdHackDeny/badip.log.ssh
#SSH拦截日志

cat /tmp/badip.log.web.tmp2 /tmp/PwdHackDeny/badip.log.web | sort | uniq -d > /tmp/badip.log.web.tmp3
cat /tmp/badip.log.web.tmp2 /tmp/badip.log.web.tmp3        | sort | uniq -u >> /tmp/PwdHackDeny/badip.log.web
#WEB拦截日志

cat /tmp/PwdHackDeny/badip.log.ssh |gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^'"$localIP"'/d'|sort|uniq -c|sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' > /tmp/PwdHackDeny/badip.ssh
cat /tmp/PwdHackDeny/badip.log.web |gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^'"$localIP"'/d'|sort|uniq -c|sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' > /tmp/PwdHackDeny/badip.web

cat /tmp/PwdHackDeny/badip.log.ssh |gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|grep "$localIP" > /tmp/PwdHackDeny/badip.ssh.local
cat /tmp/PwdHackDeny/badip.log.web |gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|grep "$localIP" > /tmp/PwdHackDeny/badip.web.local

#------------------------------------------------------------------------------------------ip-----------------------------------------------------------------------------------------

ipset list PwdHackDenySSH|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/PwdHackDenySSH.ipset
cat /tmp/PwdHackDeny/badip.ssh /tmp/PwdHackDeny/PwdHackDenySSH.ipset| sort | uniq -d > /tmp/PwdHackDeny/addedbadipSSH
cat /tmp/PwdHackDeny/badip.ssh /tmp/PwdHackDeny/addedbadipSSH       | sort | uniq -u |sed '/^'"$localIP"'/d'|sed '/^ *$/d'|sed 's/^/add '"PwdHackDenySSH"' &/g' > /tmp/PwdHackDeny/PwdHackDenySSH.to.add

if [ -s /tmp/PwdHackDeny/PwdHackDenySSH.to.add ]; then
ipset restore -f /tmp/PwdHackDeny/PwdHackDenySSH.to.add 2>/dev/null
fi

ipset list PwdHackDenyWEB|gawk '{match($0,"(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/PwdHackDenyWEB.ipset
cat /tmp/PwdHackDeny/badip.web /tmp/PwdHackDeny/PwdHackDenyWEB.ipset| sort | uniq -d > /tmp/PwdHackDeny/addedbadipWEB
cat /tmp/PwdHackDeny/badip.web /tmp/PwdHackDeny/addedbadipWEB       | sort | uniq -u |sed '/^'"$localIP"'/d'|sed '/^ *$/d'|sed 's/^/add '"PwdHackDenyWEB"' &/g' > /tmp/PwdHackDeny/PwdHackDenyWEB.to.add

if [ -s /tmp/PwdHackDeny/PwdHackDenyWEB.to.add ]; then
ipset restore -f /tmp/PwdHackDeny/PwdHackDenyWEB.to.add 2>/dev/null
fi


#---------------------------------------------------------------------------所有IP换成MAC列表再统计条数--------------------------------------------------------------------------------
#所有IP换成MAC列表再统计条数

rm -f /tmp/PwdHackDeny/badmac.ssh.tmp 2>/dev/null
rm -f /tmp/PwdHackDeny/badmac.web.tmp 2>/dev/null

badIPlistssh=`cat /tmp/PwdHackDeny/badip.ssh.local`
sumssh=`cat /tmp/PwdHackDeny/badip.ssh.local| wc -l`
if [[ $sumssh -ne 0 ]];then 
    for i in $badIPlistssh
	do
       grep "$i" /tmp/PwdHackDeny/dhcp.leases|awk '{print}' >> /tmp/PwdHackDeny/badmac.ssh.tmp
	done
fi

badIPlistweb=`cat /tmp/PwdHackDeny/badip.web.local`
sumweb=`cat /tmp/PwdHackDeny/badip.web.local| wc -l`
if [[ $sumweb -ne 0 ]];then 
    for i in $badIPlistweb
	do
       grep "$i" /tmp/PwdHackDeny/dhcp.leases|awk '{print}' >> /tmp/PwdHackDeny/badmac.web.tmp
	done
fi

cat /tmp/PwdHackDeny/badmac.ssh.tmp |awk '{print $2}'|sort|uniq -c|sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' > /tmp/PwdHackDeny/badmac.ssh
cat /tmp/PwdHackDeny/badmac.web.tmp |awk '{print $2}'|sort|uniq -c|sort -k 1 -n -r|awk '{if($1>='"$sum"') print $2}' > /tmp/PwdHackDeny/badmac.web

#-------------------------------------------------------------------------------------------mac---------------------------------------------------------------------------------------

ipset list PwdHackDenySSH_mac|gawk '{match($0,"([A-Fa-f0-9]{2}[:-]){5}[A-Fa-f0-9]{2}",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/PwdHackDenySSH_mac.ipset
cat /tmp/PwdHackDeny/badmac.ssh /tmp/PwdHackDeny/PwdHackDenySSH_mac.ipset | sort | uniq -d > /tmp/PwdHackDeny/addedbadmacSSH
cat /tmp/PwdHackDeny/badmac.ssh /tmp/PwdHackDeny/addedbadmacSSH           | sort | uniq -u |sed '/^ *$/d'|sed 's/^/add '"PwdHackDenySSH_mac"' &/g' > /tmp/PwdHackDeny/PwdHackDenySSH_mac.to.add

if [ -s /tmp/PwdHackDeny/PwdHackDenySSH_mac.to.add ]; then
ipset restore -f /tmp/PwdHackDeny/PwdHackDenySSH_mac.to.add 2>/dev/null
fi

ipset list PwdHackDenyWEB_mac|gawk '{match($0,"([A-Fa-f0-9]{2}[:-]){5}[A-Fa-f0-9]{2}",a)}{print a[0]}'|sed '/^ *$/d' > /tmp/PwdHackDeny/PwdHackDenyWEB_mac.ipset
cat /tmp/PwdHackDeny/badmac.web /tmp/PwdHackDeny/PwdHackDenyWEB_mac.ipset| sort | uniq -d > /tmp/PwdHackDeny/addedbadmacWEB
cat /tmp/PwdHackDeny/badmac.web /tmp/PwdHackDeny/addedbadmacWEB          | sort | uniq -u |sed '/^ *$/d'|sed 's/^/add '"PwdHackDenyWEB_mac"' &/g' > /tmp/PwdHackDeny/PwdHackDenyWEB_mac.to.add

if [ -s /tmp/PwdHackDeny/PwdHackDenyWEB_mac.to.add ]; then
ipset restore -f /tmp/PwdHackDeny/PwdHackDenyWEB_mac.to.add 2>/dev/null
fi

#-------------------------------------------------------------------------------------------log---------------------------------------------------------------------------------------

cat /tmp/PwdHackDeny/badip.ssh |sort -n| uniq -i |sed '/^ *$/d' > /tmp/PwdHackDeny/SSHbadip.log.tmp
cat /tmp/PwdHackDeny/badip.web |sort -n| uniq -i |sed '/^ *$/d' > /tmp/PwdHackDeny/WEBbadip.log.tmp

cat /tmp/PwdHackDeny/SSHbadip.log.tmp /etc/SSHbadip.log 2>/dev/null | sort | uniq -d > /tmp/PwdHackDeny/addlistSSH 2>/dev/null
cat /tmp/PwdHackDeny/SSHbadip.log.tmp /tmp/PwdHackDeny/addlistSSH   | sort | uniq -u |sed '/^ *$/d' > /tmp/PwdHackDeny/SSHbadip.log 2>/dev/null
if [ -s /tmp/PwdHackDeny/SSHbadip.log ]; then
cat /tmp/PwdHackDeny/SSHbadip.log >> /etc/SSHbadip.log 2>/dev/null
fi

cat /tmp/PwdHackDeny/WEBbadip.log.tmp /etc/WEBbadip.log 2>/dev/null | sort | uniq -d > /tmp/PwdHackDeny/addlistWEB 2>/dev/null
cat /tmp/PwdHackDeny/WEBbadip.log.tmp /tmp/PwdHackDeny/addlistWEB | sort | uniq -u |sed '/^ *$/d' > /tmp/PwdHackDeny/WEBbadip.log 2>/dev/null
if [ -s /tmp/PwdHackDeny/WEBbadip.log ]; then
cat /tmp/PwdHackDeny/WEBbadip.log >> /etc/WEBbadip.log 2>/dev/null
fi

#---------------------------------------------------------------------------------------------
rm -f /tmp/PwdHackDeny/badmac.ssh.log.tmp 2>/dev/null
rm -f /tmp/PwdHackDeny/badmac.web.log.tmp 2>/dev/null

badIPlistssh1=`cat /tmp/PwdHackDeny/badmac.ssh`
sumssh1=`cat /tmp/PwdHackDeny/badmac.ssh| wc -l`
if [[ $sumssh1 -ne 0 ]];then 
    for i in $badIPlistssh1
	do
       grep "$i" /tmp/PwdHackDeny/badmac.ssh.tmp|awk '{print $(1)" -> "$(2)}' >> /tmp/PwdHackDeny/badmac.ssh.log.tmp
	done
fi

badIPlistweb2=`cat /tmp/PwdHackDeny/badmac.web`
sumweb2=`cat /tmp/PwdHackDeny/badmac.web| wc -l`
if [[ $sumweb2 -ne 0 ]];then 
    for i in $badIPlistweb2
	do
       grep "$i" /tmp/PwdHackDeny/badmac.web.tmp|awk '{print $(1)" -> "$(2)}' >> /tmp/PwdHackDeny/badmac.web.log.tmp
	done
fi

cat /tmp/PwdHackDeny/badmac.ssh.log.tmp|sort -n|uniq -i|sed '/^ *$/d' > /tmp/PwdHackDeny/badmac.ssh.to.log
cat /tmp/PwdHackDeny/badmac.web.log.tmp|sort -n|uniq -i|sed '/^ *$/d' > /tmp/PwdHackDeny/badmac.web.to.log

cat /tmp/PwdHackDeny/badmac.ssh.to.log /etc/SSHbadip.log 2>/dev/null  | sort | uniq -d > /tmp/PwdHackDeny/addlistsshmac 2>/dev/null
cat /tmp/PwdHackDeny/badmac.ssh.to.log /tmp/PwdHackDeny/addlistsshmac | sort | uniq -u |sed '/^ *$/d' > /tmp/PwdHackDeny/SSHbadmac.log 2>/dev/null
if [ -s /tmp/PwdHackDeny/SSHbadmac.log ]; then
cat /tmp/PwdHackDeny/SSHbadmac.log >> /etc/SSHbadip.log 2>/dev/null
fi

cat /tmp/PwdHackDeny/badmac.web.to.log /etc/WEBbadip.log 2>/dev/null  | sort | uniq -d > /tmp/PwdHackDeny/addlistwebmac 2>/dev/null
cat /tmp/PwdHackDeny/badmac.web.to.log /tmp/PwdHackDeny/addlistwebmac | sort | uniq -u |sed '/^ *$/d' > /tmp/PwdHackDeny/WEBbadmac.log 2>/dev/null
if [ -s /tmp/PwdHackDeny/WEBbadmac.log ]; then
cat /tmp/PwdHackDeny/WEBbadmac.log >> /etc/WEBbadip.log 2>/dev/null
fi

sleep "$time"
done


