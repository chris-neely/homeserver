#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# dnf5 install -y tmux 

# List of Packages to Install
PACKAGES=(
    incus
    cronie
)

# Install Packages
dnf5 -y install "${PACKAGES[@]}"

### Configure Incus
# https://github.com/bketelsen/homer/blob/main/system_files/dx/usr/libexec/bluefin-incus
# https://discuss.linuxcontainers.org/t/incus-no-uid-gid-allocation-configured/19002/2
usermod -aG incus-admin core

echo ""
echo "Checking for necessary entries in /etc/subuid and /etc/subgid"
if grep -q "root:1000000:1000000000" /etc/subuid
then
    echo ""
    echo "  * subuid root range"
else
    echo "root:1000000:1000000000" | tee -a /etc/subuid
fi

if grep -q "root:1000000:1000000000" /etc/subgid
then
    echo ""
    echo "  * subgid root range"
else
    echo "root:1000000:1000000000" | tee -a /etc/subgid
fi

if grep -q "root:$UID:1" /etc/subgid
then
    echo ""
    echo "  * subgid root->user"
else
    echo "root:$UID:1" | tee -a /etc/subgid
fi

if grep -q "root:$UID:1" /etc/subuid
then
    echo ""
    echo "  * subuid root->user"
else
    echo "root:$UID:1" | tee -a /etc/subuid
fi

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

## Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket
systemctl enable --now inventory-server.service
systemctl enable --now crond.service
systemctl enable --now lxcfs
systemctl enable --now incus.socket
systemctl enable --now incus.service
systemctl enable --now incus-startup
