#!/bin/bash

set -ouex pipefail

rsync -rvK /tmp/system_files/ /

# Run Scripts
/tmp/build_files/install-packages.sh
/tmp/build_files/install-inventory.sh
/tmp/build_files/systemd.sh
