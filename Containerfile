FROM ghcr.io/ublue-os/cayo:fedora

#FROM ghcr.io/ublue-os/ucore-minimal:stable-nvidia-zfs

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY build_files/ /tmp/build_files/
COPY system_files/ /tmp/system_files/

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build_files/build.sh && \
    ostree container commit
