#!/bin/bash

#SCRIPT_DIR=$(pwd)
#STM32MP1_CONFIG=$SCRIPT_DIR/stm32mp1-configuration.json

#varaspwd=$(jq .database_conf.chirpstack_as_pwd  $STM32MP1_CONFIG)
#varaspwd=$(eval echo $varaspwd)

#varnspwd=$(jq .database_conf.chirpstack_ns_pwd  $STM32MP1_CONFIG)
#varnspwd=$(eval echo $varnspwd)

varfuotapwd=dbpassword

sudo -i -u postgres <<EOF
initdb -D /var/lib/postgresql/fuota_data
#pg_ctl -D /var/lib/postgresql/fuota_data -l logfile stop
pg_ctl -D /var/lib/postgresql/fuota_data -l logfile start
psql -c "create role chirpstack_fuota with login password '$varfuotapwd';"
psql -c "create database chirpstack_fuota with owner chirpstack_fuota;"
psql chirpstack_fuota -c "create extension hstore;"
EOF

