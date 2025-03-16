#!/bin/bash

set -ouex pipefail

### INSTALL PACKAGES

PACKAGES=(
    incus
    cronie
)

dnf5 -y install "${PACKAGES[@]}"
