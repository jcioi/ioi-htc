#!/bin/bash

set -eux

IMAGE=$1
BRIDGE=$2
MACADDR=$3

if [[ -n ${DISPLAY-} ]]; then
    QEMU_DISPLAY="-display sdl -vga virtio"
else
    QEMU_DISPLAY="-nographic"
fi

exec qemu-system-x86_64 \
    -machine accel=kvm -m 4G -smp 2,cores=2 -cpu host \
    -drive if=virtio,file="${IMAGE}",format=qcow2 \
    -netdev bridge,id=net0,br="${BRIDGE}" -device virtio-net-pci,netdev=net0,mac="${MACADDR}",bootindex=1 \
    -bios OVMF.fd -boot menu=on \
    $QEMU_DISPLAY
