#!/bin/sh

# copy new config
mkdir /etc/decryptkeydevice

# update device ids in in this file
cp decryptkeydevice.sh $KEYSCRIPT
chmod +x $KEYSCRIPT

cp cryptroot /etc/initramfs-tools/conf.d/cryptroot
chmod +x /etc/initramfs-tools/conf.d/cryptroot

cp decryptkeydevice.hook /etc/initramfs-tools/hooks/decryptkeydevice.hook
chmod +x /etc/initramfs-tools/hooks/decryptkeydevice.hook

# update blockids in this file
cat modules >> /etc/initramfs-tools/modules

update-initramfs -u
