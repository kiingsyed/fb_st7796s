#!/bin/bash

##### Please note this script is still under development
##### Внимание! Скрипт в стадии разработки и тестирования

##### This script should be installed AFTER KlipperScreen

SOURCES="https://github.com/evgs/fb_st7796s.git"

die() { echo "$*" 1>&2 ; exit 1; }


SCRIPT=$(realpath "$0")
SPATH=$(dirname "$SCRIPT")

KLIPPER_SCREEN_INSTALLED=$(systemctl list-units --full -all | grep -o 'KlipperScreen\.service')

if [ -z "$KLIPPER_SCREEN_INSTALLED" ]; then
    read -p "KlipperScreen service is not installed. Continue script execution? (y/n): " CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        die "Script execution aborted by user."
    fi
fi

echo "Check kernel architecture..."
UN=$(uname -a)


if echo "$UN" | grep -q sunxi64; then
    LHEADERS=linux-headers-current-sunxi64
    OVL=armbian-add-overlay
fi


if echo "$UN" | grep -q sun50iw6; then
    LHEADERS=linux-headers-next-sun50iw6
    OVL=orangepi-add-overlay
    #workaround for kernel 5.10.76
    if echo "$UN" | grep -q 5.10.76-sun50iw6; then
        LHEADERS=linux-headers-current-sun50iw6
    fi
fi

#zero2w
if echo "$UN" | grep -q sun50iw9; then
    OVL=orangepi-add-overlay
    TOUCHDOG_INSTALL_SCRIPT=touchdog-install-h618.sh
    if echo "$UN" | grep -q 6.1.31-sun50iw9; then
        LHEADERS=/opt/linux-headers*.deb
    fi
fi

[ ! -z "$LHEADERS" ] || die "Unknown kernel architecture"

#sudo apt update
sudo apt install git build-essential $LHEADERS -y || die "Error while installing packages"

cd "$SPATH"


cd "$SPATH/kernel_module/"

echo "Building driver..."
make  || die "Driver compiling fault"

echo "Installing kernel module..."
sudo make install
make clean
sudo depmod -A

echo "Appending to initramfs..."

grep -qxF 'fb_st7796s' /etc/initramfs-tools/modules || echo fb_st7796s | sudo tee /etc/initramfs-tools/modules
sudo update-initramfs -u || die "Error updating initramfs"

echo "Installing overlay..."
if echo "$UN" | grep -q sunxi64; then
    sudo $OVL "$SPATH/dts/sun8i-h3-st7796.dts" || die "Error installing overlay"
elif echo "$UN" | grep -q sun50iw6; then
    sudo $OVL "$SPATH/dts/sun50i-h6-st7796s.dts" || die "Error installing overlay"
elif echo "$UN" | grep -q sun50iw9; then
    sudo $OVL "$SPATH/dts/sun50i-h618-st7796.dts" || die "Error installing overlay"
fi

sudo systemctl stop KlipperScreen.service
sudo rm /etc/X11/xorg.conf.d/50-fbturbo.conf
sudo rm /etc/X11/xorg.conf.d/51* 
sudo rm /etc/X11/xorg.conf.d/52* 
sudo apt remove xserver-xorg-video-fbturbo
sudo apt install xserver-xorg-video-fbdev

echo "Copying xorg.conf rules..."
sudo cp "$SPATH/X11/xorg.conf.d/50"* /etc/X11/xorg.conf.d
sudo cp "$SPATH/X11/xorg.conf.d/51"* /etc/X11/xorg.conf.d
sudo cp "$SPATH/X11/Xwrapper.conf" /etc/X11/
sudo cp "$SPATH/X11/Xwrapper.conf" /etc/X11/Xwrapper.config

echo "Installing touchscreen watchdog..."
cd "$SPATH/touchdog"


if [ "$TOUCHDOG_INSTALL_SCRIPT" ]; then
    cd $SPATH/touchdog
    source "./$TOUCHDOG_INSTALL_SCRIPT"
else
    cd $SPATH/touchdog
    source ./touchdog-install.sh
fi

echo "Your need reboot your SBC to activate module"