#!/bin/sh
##网站列表查询脚本
##version 1.1
##本脚本服务于Luci，负责执行Luci下发的查询任务

#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

# 获取路由器IP
localhost=$(ifconfig  | grep "inet addr" | awk '{ print $2}' | awk -F: '{print $2}' | awk 'NR==1')
if [[ ! -n "$localhost" ]]; then
	localhost="你的路由器IP"
fi
if [ "1" == "$1" ]; then 
	if [ "`ls /opt/etc/nginx/vhost/| wc -l`" -gt 0 ]; then
		for conf in /opt/etc/nginx/vhost/*;
		do
			name=`echo $conf |awk -F"[/ .]" '{print $(NF-1)}'`
			port=`cat $conf | awk 'NR==2' | awk '{print $2}' | sed 's/;//'`
			echo -n "$localhost:$port $name "
		done
	fi
else 
	echo -n `ls /opt/etc/nginx/vhost | wc -l`
fi
