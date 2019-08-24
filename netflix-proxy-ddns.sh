#!/bin/sh

if [ ! -f "/tmp/current_ip.txt" ]
then
    CURRENT_IP=`curl -s http://ipv4.ip.sb`
    echo $CURRENT_IP > /tmp/current_ip.txt
fi
NEW_IP=`curl -s http://ipv4.ip.sb`
CURRENT_IP=`cat /tmp/current_ip.txt`
if [ "$NEW_IP" = "$CURRENT_IP" ]
then
echo "No Change in IP Adddress"
else
sed -i "s/$CURRENT_IP/$NEW_IP/g" /root/netflix-proxy/dnsmasq.conf
service netflix-proxy-admin restart
echo $NEW_IP > /tmp/current_ip.txt
fi