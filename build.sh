#!/bin/bash

set -ouex pipefail

rsync -rvK /tmp/system_files/ /

/tmp/build-install-packages.sh
/tmp/build-install-inventory.sh
/tmp/build-systemd.sh
