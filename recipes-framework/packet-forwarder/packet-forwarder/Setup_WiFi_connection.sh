#!/bin/bash -

echo "WiFi setup connection"
ifconfig wlan0 up
iw dev wlan0 scan |grep SSID
echo "your SSID must be in the list above"

echo "Enter your SSID: "
read SSID
echo "Enter your password: "
read PSWD

sed -i".bak" '5,$d' /etc/wpa_supplicant.conf

wpa_passphrase "$SSID" "$PSWD" >> /etc/wpa_supplicant.conf

sed -i".bak" '7d' /etc/wpa_supplicant.conf

echo "In case you made a mistake in your SSID or password you can change them
in the file wpa_supplicant.conf, with the command cat
/etc/wpa_supplicant.conf and relaunch this script"
echo "if you key is not WPA change 'psk=...' with 'key_mgmt=NONE' in the same file"

