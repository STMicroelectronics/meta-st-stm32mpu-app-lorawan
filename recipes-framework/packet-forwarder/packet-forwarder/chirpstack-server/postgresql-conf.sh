#!/bin/bash

SCRIPT_DIR=$(pwd)
STM32MP1_CONFIG=$SCRIPT_DIR/stm32mp1-configuration.json 

varaspwd=$(jq .database_conf.chirpstack_as_pwd  $STM32MP1_CONFIG)
varaspwd=$(eval echo $varaspwd)

varnspwd=$(jq .database_conf.chirpstack_ns_pwd  $STM32MP1_CONFIG)
varnspwd=$(eval echo $varnspwd) 

varfuotapwd=$(jq .database_conf.chirpstack_fuota_pwd  $STM32MP1_CONFIG)
varfuotapwd=$(eval echo $varfuotapwd)

sudo -i -u postgres <<EOF
initdb -D /var/lib/postgresql/data
#pg_ctl -D /var/lib/postgresql/data -l logfile stop
pg_ctl -D /var/lib/postgresql/data -l logfile start
psql -c "create role chirpstack_as with login password '$varaspwd';"
psql -c "create role chirpstack_ns with login password '$varnspwd';"
psql -c "create role chirpstack_fuota with login password '$varfuotapwd';"
psql -c "create database chirpstack_as with owner chirpstack_as;"
psql -c "create database chirpstack_ns with owner chirpstack_ns;"
psql -c "create database chirpstack_fuota with owner chirpstack_fuota;"
psql chirpstack_as -c "create extension pg_trgm;"
psql chirpstack_as -c "create extension hstore;"
psql chirpstack_fuota -c "create extension hstore;"
EOF





