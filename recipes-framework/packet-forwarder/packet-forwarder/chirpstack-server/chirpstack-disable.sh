#!/bin/bash


sudo -i -u postgres <<EOF
pg_ctl -D /var/lib/postgresql/data -l logfile stop
EOF

sleep 0.5
echo "Disable chirpstack-network-server "
sudo systemctl stop chirpstack-gateway-bridge
sudo systemctl disable chirpstack-gateway-bridge
 

sleep 0.5
echo "Disable chirpstack-application-server"
sudo systemctl stop chirpstack-network-server
sudo systemctl disable chirpstack-network-server


sleep 0.5
echo "Disable chirpstack-gateway-bridge"
sudo systemctl stop chirpstack-application-server
sudo systemctl disable chirpstack-application-server


sleep 0.5


