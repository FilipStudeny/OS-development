#!/bin/sh

# Stop on error
set -e

# Run QEMU with the boot image
qemu-system-x86_64 \
  -drive format=raw,file=boot.img \
  -boot order=c \
  -no-reboot
