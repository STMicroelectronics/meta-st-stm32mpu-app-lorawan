#!/bin/bash - 

echo "Gateway EUI is: "
jq -r '.gateway_conf.gateway_ID' global_conf.json
echo "The hostname is: "
jq -r '.gateway_conf.server_address' global_conf.json
echo "The port up is: "
jq -r '.gateway_conf.serv_port_up' global_conf.json
echo "The port down is: "
jq -r '.gateway_conf.serv_port_down' global_conf.json

#Treat unset variables as an error
echo "launch of the cortex m4 firmware"
./launch_m4_firmware.sh start
sleep 3
echo "stty echo"
stty -onlcr -echo -F /dev/ttyRPMSG0
sleep 1
stty -onlcr -echo -F /dev/ttyRPMSG1
sleep 1
#to enable ttyRPMSG1
echo launch > /dev/ttyRPMSG1
echo "to stop the firmware : echo stop > /sys/class/remoteproc/remoteproc0/state"

sleep 5

echo "launch the program on the A7"
./lora_pkt_fwd
