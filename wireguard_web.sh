#!/bin/bash


apt-get update -y
apt-get install -y software-properties-common
add-apt-repository -y ppa:wireguard/wireguard
apt-get update -y
apt-get install -y wireguard


apt-get remove -y dnsmasq


modprobe wireguard
modprobe iptable_nat
modprobe ip6table_nat


cat > /etc/init.d/wgwebstart <<-EOF
#! /bin/bash
### BEGIN INIT INFO
# Provides:		wgwebstart
# Required-Start:	$remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	wgwebstart
### END INIT INFO
modprobe wireguard
modprobe iptable_nat
modprobe ip6table_nat
docker start subspace
EOF

chmod 755 /etc/init.d/wgwebstart
update-rc.d wgwebstart defaults

read -p "输入域名：" domain

docker create \
--name subspace \
--network host \
--cap-add NET_ADMIN \
--volume /usr/bin/wg:/usr/bin/wg \
--volume /data:/data \
--env SUBSPACE_HTTP_HOST=$domain \
subspacecloud/subspace:latest


docker start subspace

echo "安装完毕，使用浏览器访问域名，配置初始登录账号。"