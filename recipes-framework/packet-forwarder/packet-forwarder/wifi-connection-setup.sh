#!/bin/bash

export NCURSES_NO_UTF8_ACS=1

SCRIPT_DIR=$(pwd)

service_exists(){
    local n=$1
    if [[ $(systemctl list-units --all -t service --full --no-legend "$n.service" | cut -f1 -d' ') == $n.service ]]; then
        return 0
    else
        return 1
    fi
}


ifconfig wlan0 up
iw dev wlan0 scan |grep SSID
echo "your SSID must be in the list above"

echo "Enter your SSID: "
read SSID
echo "Enter your password: "
read PSWD

sed -i".bak" '5,$d' /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

wpa_passphrase "$SSID" "$PSWD" >> /etc/wpa_supplicant/wpa_supplicant-wlan0.conf


echo "In case you made a mistake in your SSID or password you can change them
in the file wpa_supplicant-wlan0.conf with the command cat
/etc/wpa_supplicant/wpa_supplicant-wlan0.conf and relaunch this script"
 
mkdir -p /usr/lib/systemd/network	
cp $SCRIPT_DIR/51-wireless.network /usr/lib/systemd/network/
systemctl enable wpa_supplicant@wlan0.service
systemctl enable systemd-networkd.service
systemctl restart systemd-networkd.service
systemctl restart wpa_supplicant@wlan0.service

