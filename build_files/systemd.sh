#!/bin/bash

set -ouex pipefail

# Enable Services
systemctl enable homeserver-groups.service
systemctl enable tailscaled.service
systemctl enable inventory-server.service
systemctl enable crond.service
systemctl enable lxcfs
systemctl enable incus.socket
systemctl enable incus.service
systemctl enable incus-startup
