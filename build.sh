#!/bin/bash

set -ouex pipefail

### COPY SYSTEM FILES

rsync -rvK /tmp/system_files/ /
chmod 755 /usr/libexec/homeserver-groups
chmod +x /usr/libexec/homeserver-groups

### INSTALL PACKAGES

PACKAGES=(
    incus
    cronie
)

dnf5 -y install "${PACKAGES[@]}"

### INSTALL INVENTORY
# https://bketelsen.github.io/inventory/docs/installation/#installer-script 
sh -c "$(curl --location https://bketelsen.github.io/inventory/install.sh)" -- -d -b /usr/local/bin

# Inventory Config File
# https://github.com/bketelsen/inventory/blob/main/README.md
mkdir -p /etc/inventory
tee /etc/inventory/inventory <<'EOF'
server:
  address: "127.0.0.1:8000"
verbose: false
EOF
chmod 755 /etc/inventory/inventory

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
chown root:root /etc/logrotate.d/inventory
firewall-cmd --permanent --zone=FedoraServer --add-port=8000/tcp

### ENABLE SERVICES

systemctl enable homeserver-groups.service
systemctl enable tailscaled.service
systemctl enable inventory-server.service
systemctl enable crond.service
systemctl enable lxcfs
systemctl enable incus.socket
systemctl enable incus.service
systemctl enable incus-startup
systemctl enable docker.service
systemctl enable docker.socket
