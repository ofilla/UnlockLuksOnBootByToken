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

function initAutoUnlockOnBootConfig_using_initcpio() {
    cp files/decryptkeydevice.initcpio.hook /etc/initcpio/hooks/decryptkeydevice
    cp files/decryptkeydevice.initcpio.install /etc/initcpio/install/decryptkeydevice

    cat > /etc/decryptkeydevice.conf <<EOF
# configuration for decryptkeydevice
#

# ID(s) of the USB/MMC key(s) for decryption (sparated by blanks)
# as listed in /dev/disk/by-id/
DECRYPTKEYDEVICE_DISKID="$KEY_DEVICE_IDS"

# blocksize usually 512 is OK
DECRYPTKEYDEVICE_BLOCKSIZE="$BLOCKSIZE"

# start of key information on keydevice DECRYPTKEYDEVICE_BLOCKSIZE * DECRYPTKEYDEVICE_SKIPBLOCKS
DECRYPTKEYDEVICE_SKIPBLOCKS="$KEY_DEVICE_KEYFILE_STARTS_AT"

# length of key information on keydevice DECRYPTKEYDEVICE_BLOCKSIZE * DECRYPTKEYDEVICE_READBLOCKS
DECRYPTKEYDEVICE_READBLOCKS="$BLOCK_NUMBER"
EOF

    chmod 600 /etc/decryptkeydevice.conf
    chmod 600 /etc/initcpio/hooks/decryptkeydevice
    chmod 600 /etc/initcpio/install/decryptkeydevice

    sed -i '/^HOOKS=/s/encrypt/decryptkeydevice encrypt/' /etc/mkinitcpio.conf
    mkinitcpio -P
}

if [[ -d /etc/initramfs-tools ]]; then
    initAutoUnlockOnBootConfig_using_initramfs
elif [[ -d /etc/initcpio ]]; then
    initAutoUnlockOnBootConfig_using_initcpio
fi
