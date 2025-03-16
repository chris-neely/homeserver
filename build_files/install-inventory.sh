#!/bin/bash

set -ouex pipefail

### Install Inventory
# https://bketelsen.github.io/inventory/docs/installation/#installer-script 
sh -c "$(curl --location https://bketelsen.github.io/inventory/install.sh)" -- -d -b /usr/local/bin

# Inventory Config File
# https://github.com/bketelsen/inventory/blob/main/README.md
mkdir -p /etc/inventory
tee /etc/inventory/inventory <<'EOF'
server:
  address: "127.0.0.1:9999"
verbose: false
EOF

# Inventory Service
tee /etc/systemd/system/inventory-server.service <<'EOF'
[Unit]
Description=Inventory Server
After=network.target
Requires=network.target

[Service]
Type=notify

Restart=always
RestartSec=30
TimeoutStartSec=0

WorkingDirectory=/var/home/core
ExecStart=/usr/local/bin/inventory serve
User=core
Group=core
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

# Inventory CRON Job
# https://bketelsen.github.io/inventory/docs/cli/inventory_send/
echo "*/2 * * * * root /usr/local/bin/inventory send >> /var/log/inventory.log 2>&1" >> /etc/crontab

# Inventory Log Rotation
tee /etc/logrotate.d/inventory <<'EOF'
/var/log/inventory.log {
       copytruncate
       daily
       rotate 7
       delaycompress
       compress
       notifempty
       missingok
}
EOF
chmod 644 /etc/logrotate.d/inventory
chown root.root /etc/logrotate.d/inventory
