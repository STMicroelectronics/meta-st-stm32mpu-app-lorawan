#! /bin/bash

echo "Gateway EUI is: "
jq -r '.gateway_conf.gateway_ID' global_conf.json
echo "The hostname is: "
jq -r '.gateway_conf.server_address' global_conf.json
echo "The port up is: "
jq -r '.gateway_conf.serv_port_up' global_conf.json
echo "The port down is: "
jq -r '.gateway_conf.serv_port_down' global_conf.json

echo "Reset GPIO 11 on STM32MP1"
gpioset gpiochip6 8=1
sleep 0.1
#echo "set to 1"
gpioset gpiochip6 8=0
#echo "set to 0"
sleep 0.1
gpioget gpiochip6 8
sleep 0.5
./lora_pkt_fwd
