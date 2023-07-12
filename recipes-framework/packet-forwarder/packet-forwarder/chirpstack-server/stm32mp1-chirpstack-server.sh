#!/bin/bash

echo "Gateway EUI is: "
jq -r '.gateway_conf.gateway_ID' global_conf.json
echo "The hostname is: "
jq -r '.gateway_conf.server_address' global_conf.json
echo "The port up is: "
jq -r '.gateway_conf.serv_port_up' global_conf.json
echo "The port down is: "
jq -r '.gateway_conf.serv_port_down' global_conf.json

./chirpstack-enable.sh
./concentrator-reset.sh
./lora_pkt_fwd
