#!/bin/sh
set -e

# Assemble boot sector
nasm -f bin boot.asm -o boot.bin

# Ensure boot.bin is exactly 512 bytes
if [ "$(stat -c%s boot.bin)" -ne 512 ]; then
    echo "Error: boot.bin must be exactly 512 bytes"
    exit 1
fi

# Create a raw 512-byte disk image
dd if=/dev/zero of=boot.img bs=512 count=1

# Write boot sector into the image
dd if=boot.bin of=boot.img bs=512 count=1 conv=notrunc
