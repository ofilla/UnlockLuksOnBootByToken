#!/bin/bash
# generates a decryption key for the current $KEY_DEVICE

# go to directory containing this file
cd "$(dirname "$BASH_SOURCE[0]")"
# load config
. decryptkeydevice.conf

function generateKeyForCurrentDevice (
    device=$1

    blocks_to_write=$(($KEY_DEVICE_LAST_WRITABLE - $KEY_DEVICE_FIRST_WRITABLE))
    dd if=/dev/urandom of=$device bs=$BLOCKSIZE seek=$KEY_DEVICE_FIRST_WRITABLE count=$blocks_to_write

    dd if=$device bs=$BLOCKSIZE skip=$KEY_DEVICE_KEYFILE_STARTS_AT count=$BLOCK_NUMBER of=tempKeyFile.bin

    cryptsetup luksAddKey $CRYPTROOT_DEVICE tempKeyFile.bin

    echo "Created keyfile on $device at $KEY_DEVICE_KEYFILE_STARTS_AT"
    unset device
)

generateKeyForCurrentDevice $KEY_DEVICE
