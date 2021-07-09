#!/bin/bash

# go to directory containing this file
cd "$(dirname "$BASH_SOURCE[0]")"
# load config
. decryptkeydevice.conf

function configure_keyscript() {
    keyscript="$1"

    sed -i "s:\$KEY_DEVICE_IDS:$KEY_DEVICE_IDS:" $keyscript
    sed -i "s:\$BLOCKSIZE:$BLOCKSIZE:" $keyscript
    sed -i "s:\$KEY_DEVICE_KEYFILE_STARTS_AT:$KEY_DEVICE_KEYFILE_STARTS_AT:" $keyscript
    sed -i "s:\$BLOCK_NUMBER:$BLOCK_NUMBER:" $keyscript
    chmod 700 $keyscript
}

function initAutoUnlockOnBootConfig_using_initramfs() {
    # copy new config
    mkdir /etc/decryptkeydevice

    # update device ids in in this file
    cp files/decryptkeydevice.sh $KEYSCRIPT
    configure_keyscript $KEYSCRIPT

    echo "source=$CRYPTROOT_DEVICE,target=$ROOT_NAME,lvm=$LVM_ROOT,keyscript=$KEYSCRIPT,key=$KEY_DEVICE" > /etc/initramfs-tools/conf.d/cryptroot
    chmod +x /etc/initramfs-tools/conf.d/cryptroot

    cp files/decryptkeydevice.initramfs.hook /etc/initramfs-tools/hooks/decryptkeydevice.hook
    chmod +x /etc/initramfs-tools/hooks/decryptkeydevice.hook

    # update blockids in this file
    cat files/modules >> /etc/initramfs-tools/modules

    update-initramfs -u
}

initAutoUnlockOnBootConfig_using_initramfs
