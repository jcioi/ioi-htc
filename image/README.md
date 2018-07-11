## Prerequisite
- packer (need to build unreleased version; affected by [hashicorp/packer#6432](https://github.com/hashicorp/packer/issues/6432))
- qemu-system-x86
- qemu-utils (for `qemu-img`)
- libguestfs-tools (for `virt-sparsify`)
- pigz
- apt-cacher-ng (or some other caching proxy; optional)
