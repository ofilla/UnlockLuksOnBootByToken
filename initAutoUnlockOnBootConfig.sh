#!/bin/bash

# go to directory containing this file
cd "$(dirname "$BASH_SOURCE[0]")"
# load config
. decryptkeydevice.conf

function initAutoUnlockOnBootConfig_using_initramfs() {
    # copy new config
    mkdir /etc/decryptkeydevice

    # update device ids in in this file
    cp decryptkeydevice.sh $KEYSCRIPT
    chmod +x $KEYSCRIPT

    echo "source=$CRYPTROOT_DEVICE,target=$ROOT_NAME,lvm=$LVM_ROOT,keyscript=$KEYSCRIPT,key=$KEY_DEVICE" > /etc/initramfs-tools/conf.d/cryptroot
    chmod +x /etc/initramfs-tools/conf.d/cryptroot

    cp decryptkeydevice.hook /etc/initramfs-tools/hooks/decryptkeydevice.hook
    chmod +x /etc/initramfs-tools/hooks/decryptkeydevice.hook

    # update blockids in this file
    cat modules >> /etc/initramfs-tools/modules

    update-initramfs -u
}

initAutoUnlockOnBootConfig_using_initramfs
