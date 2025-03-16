#!/bin/bash

set -ouex pipefail

# build scripts
/tmp/build_files/install-packages.sh
/tmp/build_files/install-inventory.sh
/tmp/build_files/install-system-files.sh
/tmp/build_files/enable-services.sh
