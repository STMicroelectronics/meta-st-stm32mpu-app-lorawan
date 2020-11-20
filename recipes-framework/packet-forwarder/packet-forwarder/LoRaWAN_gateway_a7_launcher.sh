#! /bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

SCRIPT_DIR=$(pwd)

error() {
	echo -e "$1"
	exit 0
}

case $1 in
	wifi) ;;
	ethernet) ;;
	*) echo "`basename ${0}`:usage: wifi | ethernet"
	   exit 1
	   ;;
esac

echo "LoRaWan Gateway launcher"

sleep 0.2
./update_gwid.sh ./local_conf.json
./update_gwid.sh ./global_conf.json
sleep 0.2
./set_network_server_infos.sh
sleep 0.2


#################
# Ethernet #
#################
if [ "$1" == "ethernet" ]
then

echo "System running on an ethernet connection"
echo "enabling lorawan-gateway-a7 service, to run on an ethernet connection"
cp $SCRIPT_DIR/lorawan-gateway-a7.service /lib/systemd/system/
systemctl enable lorawan-gateway-a7.service

fi

#################
# wifi #
#################
if [ "$1" == "wifi" ]
then

echo "System running on a wifi connection"

./Setup_WiFi_connection.sh

echo "enabling lorawan-gateway-a7-wifi service, to run on a wifi connection"
cp $SCRIPT_DIR/lorawan-gateway-a7-wifi.service /lib/systemd/system/
systemctl enable lorawan-gateway-a7-wifi.service

fi

echo "The system will reboot in 5 seconds..."
sleep 5
reboot
