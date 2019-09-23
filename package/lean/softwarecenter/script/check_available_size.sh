#!/bin/sh
#check usb disk size
#version: 1.0

#
# Copyright (C) 2019 Jianpeng Xiang (1505020109@mail.hnust.edu.cn)
#
# This is free software, licensed under the GNU General Public License v3.
#

# 加载通用函数库
. /usr/bin/softwarecenter/lib_functions.sh

check_available_size "$1"
