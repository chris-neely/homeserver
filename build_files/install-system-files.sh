#!/bin/bash

set -ouex pipefail

### COPY SYSTEM FILES

rsync -rvK /tmp/system_files/ /
chmod 755 /usr/libexec/homeserver-groups
chmod +x /usr/libexec/homeserver-groups
