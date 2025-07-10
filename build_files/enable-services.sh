#!/bin/bash

set -ouex pipefail

### ENABLE SERVICES

systemctl enable homeserver-groups.service
systemctl enable tailscaled.service
#systemctl enable inventory-server.service
systemctl enable crond.service
systemctl enable lxcfs
systemctl enable incus.socket
systemctl enable incus.service
systemctl enable incus-startup
#systemctl enable docker.service
#systemctl enable docker.socket
systemctl enable cockpit.service
