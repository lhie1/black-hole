#!/usr/bin/env bash
while :
do
	for i in `netstat -tlnp |grep -E "152|153|156|21111|21112|21113|873|1099" |awk '$2 >128 {print $7}' |cut -d"/" -f1 |awk '!a[$0]++'`
	do
		for j in `docker inspect -f "{{.Id}} {{.State.Pid}}"  $(docker ps -q)|grep $i |awk '{print $1}'`
		do 
			docker restart $j && echo `date` >>/root/ssdaemon.log
		done
	done
	sleep 5
done