#!/bin/bash
# Build and install xrdp with pulseaudio sink module on RASPBIAN STRETCH
# Aug. 21 2017
# Signal Flag "Z"
# https://signal-flag-z.blogspot.com/
# Copyright (c) 2017, Signal Flag "Z"  All rights reserved.

#
sudo apt update -y
sudo apt upgrade -y

#xrdp script
cd ~/Downloads
sudo apt install -y autoconf libtool libssl-dev libpam0g-dev libfuse-dev libmp3lame-dev libpixman-1-dev libx11-dev libxfixes-dev libxrandr-dev xserver-xorg-dev
git clone https://github.com/neutrinolabs/xrdp.git
git clone https://github.com/neutrinolabs/xorgxrdp.git
cd xrdp
git checkout refs/tags/v0.9.3.1
git submodule init
git submodule update
./bootstrap
./configure --enable-fuse --enable-mp3lame --enable-pixman
sudo make -j4
sudo make install
cd ..
#xorgxrdp
cd xorgxrdp
sudo ./bootstrap
sudo ./configure
sudo make -j4
sudo make install
cd ..
#
sudo sed -i.bak 's/^\(EnvironmentFile.*sysconfig.*\)/#\1/' /lib/systemd/system/xrdp.service
sudo sed -i 's/^\(EnvironmentFile.*\)\(\/etc\/default\/xrdp\)/\1\/etc\/xrdp/' /lib/systemd/system/xrdp.service
sudo sed -i.bak 's/^\(EnvironmentFile.*sysconfig.*\)/#\1/' /lib/systemd/system/xrdp-sesman.service
sudo sed -i 's/^\(EnvironmentFile.*\)\(\/etc\/default\/xrdp\)/\1\/etc\/xrdp/' /lib/systemd/system/xrdp-sesman.service

# pulseaudio sink
sudo apt install -y pulseaudio
sudo apt install -y intltool libsndfile1-dev libspeex-dev libspeexdsp-dev libcap-dev

#
cd ~/Downloads
wget https://freedesktop.org/software/pulseaudio/releases/pulseaudio-10.0.tar.gz
tar -zxvf pulseaudio-10.0.tar.gz
cd ~/Downloads/pulseaudio-10.0

#
./configure
cd ~/Downloads/xrdp/sesman/chansrv/pulse
myHome=`echo -n ~`
sed -i "s#PULSE_DIR = /tmp/pulseaudio-10.0#PULSE_DIR = ${myHome}/Downloads/pulseaudio-10.0#g" Makefile
sed -ie '/CFLAGS/s/fPIC$/fPIC -DXRDP_SOCKET_PATH=\"\/tmp\/.xrdp\"/g' Makefile
sudo make
sudo cp *.so /usr/lib/pulse-10.0/modules/
cd ~

#
sudo systemctl daemon-reload
sudo systemctl enable xrdp.service
sudo systemctl start xrdp.service

echo 'Completed. Reboot now.'
