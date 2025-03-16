# Homeserver

> [!WARNING]
> This is a work in progress with heavy testing happening in the master branch of this repo. Use at your own risk.

My custom [ucore](https://github.com/ublue-os/ucore) homeserver image generated by the [ublue-os/image_template](https://github.com/ublue-os/image-template).

# Image modification
- [_lxc_/incus](https://github.com/lxc/incus) is a modern, secure and powerful system container and virtual machine manager.
- [_bketelsen_/inventory](https://github.com/bketelsen/inventory) is an application that tracks deployed services/containers. It was built with a homelab in mind.

# Base Image
- [ucore/fedora-coreos:stable-nvidia-zfs](https://github.com/ublue-os/ucore?tab=readme-ov-file#tag-matrix)

#### `fedora-coreos`

A generic [Fedora CoreOS image](https://quay.io/repository/fedora/fedora-coreos?tab=tags) image with choice of add-on kernel modules:

- [nvidia versions](#tag-matrix) add:
  - [nvidia driver](https://github.com/ublue-os/akmods) - latest driver built from negativo17's akmod package
  - [nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/sample-workload.html) - latest toolkit which supports both root and rootless podman containers and CDI
  - [nvidia container selinux policy](https://github.com/NVIDIA/dgx-selinux/tree/master/src/nvidia-container-selinux) - allows using `--security-opt label=type:nvidia_container_t` for some jobs (some will still need `--security-opt label=disable` as suggested by nvidia)
- [ZFS versions](#tag-matrix) add:
  - [ZFS driver](https://github.com/ublue-os/akmods) - latest driver (currently pinned to 2.2.x series)

> [!NOTE]
> zincati fails to start on all systems with OCI based deployments (like uCore). Upstream efforts are active to develop an alternative.
