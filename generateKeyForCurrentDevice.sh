#!/bin/sh
# generates a decryption key for the current $KEY_DEVICE

blocks_to_write=$(($KEY_DEVICE_LAST_WRITABLE - $KEY_DEVICE_FIRST_WRITABLE))
dd if=/dev/urandom of=$KEY_DEVICE bs=$BLOCKSIZE seek=$KEY_DEVICE_FIRST_WRITABLE count=$blocks_to_write

dd if=$KEY_DEVICE bs=$BLOCKSIZE skip=$KEY_DEVICE_START count=$BLOCK_NUMBER of=tempKeyFile.bin

cryptsetup luksAddKey $CRYPTROOT_DEVICE tempKeyFile.bin
