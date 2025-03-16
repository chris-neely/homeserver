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

# Install Inventory
# https://bketelsen.github.io/inventory/docs/installation/#installer-script 
sh -c "$(curl --location https://bketelsen.github.io/inventory/install.sh)" -- -d -b /usr/local/bin

# Inventory Config File
# https://github.com/bketelsen/inventory/blob/main/README.md
mkdir -p ~/.inventory
tee ~/.inventory/inventory <<'EOF'
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

#Inventory CRON Job
# https://bketelsen.github.io/inventory/docs/cli/inventory_send/
echo "*/2 * * * * /usr/local/bin/inventory send  >> /var/log/inventory.log 2>&1" >> /etc/crontab


## Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket
systemctl enable inventory-server.service
systemctl enable crond.service
