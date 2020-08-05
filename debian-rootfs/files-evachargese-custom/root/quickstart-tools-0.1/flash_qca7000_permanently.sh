#!/bin/sh
#
#  Copyright (c) 2016 I2SE GmbH
#

otp=`cat /sys/fsl_otp/HW_OCOTP_CUST2`

mac=`/root/otp2mac.sh $otp 00:01:87`

if [ $# -lt 1 ]; then
	cat >&2 <<EOU
Usage: $0 PIBFILE [FIRMWAREFILE] [BOOTLOADERFILE]
  PIBFILE         PIB configuration for QCA7000
  FIRMWAREFILE    Firmware for QCA7000
  BOOTLOADERFILE  Bootloader for QCA7000
EOU
	exit 1
fi

BL="$3"
FW="$2"
PIB=/tmp/pib

if [ "$BL" = "" ]; then
BL=NvmSoftloader-QCA7000-v1.1.0-01-FINAL.nvm
fi

if [ "$FW" = "" ]; then
FW=MAC-QCA7000-v1.1.0-01-X-FINAL.nvm
fi

cp "$1" /tmp/pib

if [ ! -f "$BL" ]; then
	echo "No bootloader image found"
	exit 1
fi

if [ ! -f "$PIB" ]; then
	echo "No PIB file found"
	exit 1
fi

if [ ! -f "$FW" ]; then
	echo "No firmware image found"
	exit
fi

# Adapt MAC address in PIB file
modpib -M $mac -v /tmp/pib

/root/evse-gpio.sh export

# Force QCA7000 into bootloader mode
echo out > /sys/class/gpio/gpio46/direction
echo 0 > /sys/class/gpio/gpio46/value

# Reset QCA7000
echo out > /sys/class/gpio/gpio45/direction
echo in > /sys/class/gpio/gpio45/direction

# Flash firmware permanently
/usr/local/bin/plcboot -N "$FW" -P /tmp/pib -S "$BL" -i qca0 -F

# Avoid QCA7000 bootloader mode
echo in > /sys/class/gpio/gpio46/direction

# Reset QCA7000
echo out > /sys/class/gpio/gpio45/direction
echo in > /sys/class/gpio/gpio45/direction
