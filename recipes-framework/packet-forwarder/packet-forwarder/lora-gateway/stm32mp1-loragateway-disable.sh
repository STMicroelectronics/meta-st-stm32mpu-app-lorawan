#! /bin/bash

echo "Disable STM32MP1 Gateway" 

systemctl stop stm32mp1-loragateway.service
systemctl disable stm32mp1-loragateway.service
systemctl stop stm32mp1-loragateway-wifi.service
systemctl disable stm32mp1-loragateway-wifi.service

./reset_lgw.sh stop

 
