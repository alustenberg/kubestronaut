#!/bin/bash

set -x

export DEBIAN_FRONTEND=noninteractive
export HISTSIZE=0

growpart /dev/vda 2
lvextend -r /dev/vg0/root -L4G
lvextend -r /dev/vg0/var /dev/vda2

apt-get -y autoremove;
apt-get -y clean;
fstrim -a;

sleep 5;
