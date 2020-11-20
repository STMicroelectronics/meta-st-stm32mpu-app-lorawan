#!/bin/bash -

echo "WiFi launch"

echo "Try to connect to the SSID"
wpa_supplicant -B -iwlan0 -c /etc/wpa_supplicant.conf
iw wlan0 link
echo "please wait"
dhclient wlan0
ip addr show wlan0

echo "test connexion"
ping -c 5 google.com

echo "WiFi launch script over"

