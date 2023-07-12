#!/bin/bash


sudo -i -u postgres <<EOF
pg_ctl -D /var/lib/postgresql/data -l logfile start
EOF

echo "start chirpstack-network-server "
systemctl enable chirpstack-gateway-bridge.service
systemctl start chirpstack-gateway-bridge.service

echo "start chirpstack-application-server"
systemctl enable chirpstack-network-server.service
systemctl start chirpstack-network-server.service

echo "start chirpstack-gateway-bridge"
systemctl enable chirpstack-application-server.service
systemctl start chirpstack-application-server.service




