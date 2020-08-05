#!/bin/sh
#
#  Copyright (c) 2016 I2SE GmbH
#

STATUS=`brctl show | grep br0`

if [ "$1" = "enable" ]; then
	if [ "$STATUS" != "" ]; then
		echo "br0 already enabled"
		exit 0
    fi
	brctl addbr br0
	brctl addif br0 qca0
	brctl addif br0 eth0
	brctl setfd br0 0
	ifconfig br0 192.168.37.251
	ifconfig br0 up
	ifconfig eth0 up
elif [ "$1" = "disable" ]; then
	if [ "$STATUS" = "" ]; then
		echo "br0 already disabled"
		exit 0
	fi
	brctl delif br0 eth0
	brctl delif br0 qca0
	ifconfig br0 down
	brctl delbr br0
else
	echo "Usage: $0 (enable|disable)"
	exit 1
fi
