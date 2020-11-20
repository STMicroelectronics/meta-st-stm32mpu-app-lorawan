#!/bin/bash -
#===============================================================================
#
#          FILE: set_network_server_infos.sh
#
#         USAGE: ./set_network_server_infos.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: SERGENT Hugo (),
#  ORGANIZATION: STMicroelectronics
#     COPYRIGHT: Copyright (C) 2019, STMicroelectronics - All Rights Reserved
#       CREATED: 04/01/2019 02:00:44 PM
#      REVISION:  ---
#===============================================================================
printf "Update of the configuration files (.json) that define the network options
"


printf "       Server address [default = localhost]:"
read SERVER_ADDRESS
if [[ $SERVER_ADDRESS == "" ]]; then SERVER_ADDRESS="localhost"; fi
printf "       Server port up[default = 1700]:"
read SERVER_PORT_UP
if [[ $SERVER_PORT_UP == "" ]]; then SERVER_PORT_UP="1700"; fi
printf "       Server port down[default = 1700]:"
read SERVER_PORT_DOWN
if [[ $SERVER_PORT_DOWN == "" ]]; then SERVER_PORT_DOWN="1700"; fi


tmp=$(mktemp)
jq -r --arg SERVER_ADDRESS "$SERVER_ADDRESS" '.gateway_conf.server_address = $SERVER_ADDRESS' global_conf.json > "$tmp" && mv "$tmp"  global_conf.json
jq -r --arg SERVER_PORT_UP "$SERVER_PORT_UP" '.gateway_conf.serv_port_up = ($SERVER_PORT_UP | tonumber)' global_conf.json > "$tmp" && mv "$tmp"  global_conf.json
jq -r --arg SERVER_PORT_DOWN "$SERVER_PORT_DOWN" '.gateway_conf.serv_port_down = ($SERVER_PORT_DOWN | tonumber)' global_conf.json > "$tmp" && mv "$tmp"  global_conf.json

jq -r --arg SERVER_PORT_UP "$SERVER_PORT_UP" '.gateway_conf.serv_port_up = ($SERVER_PORT_UP | tonumber)' local_conf.json > "$tmp" && mv "$tmp"  local_conf.json
jq -r --arg SERVER_PORT_DOWN "$SERVER_PORT_DOWN" '.gateway_conf.serv_port_down = ($SERVER_PORT_DOWN | tonumber)' local_conf.json > "$tmp" && mv "$tmp"  local_conf.json


echo "Gateway EUI is: "
jq -r '.gateway_conf.gateway_ID' global_conf.json
echo "The hostname is: "
jq -r '.gateway_conf.server_address' global_conf.json
echo "The port up is: "
jq -r '.gateway_conf.serv_port_up' global_conf.json
echo "The port down is: "
jq -r '.gateway_conf.serv_port_down' global_conf.json
