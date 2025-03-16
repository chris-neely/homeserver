#!/bin/bash

set -ouex pipefail

# List of Packages to Install
PACKAGES=(
    incus
    cronie
)

# Install Packages
dnf5 -y install "${PACKAGES[@]}"
