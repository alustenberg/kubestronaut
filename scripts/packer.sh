#!/bin/bash

set -x
export DEBIAN_FRONTEND=noninteractive

apt -y update
apt -y upgrade
apt -y install \
    apt-transport-https \
    bash-completion \
    curl \
    gpg \
    locate \
    net-tools \
    nfs-common \
    systemd-timesyncd \
    unzip \
    ;

cat > /etc/default/grub <<EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Ubuntu"
GRUB_CMDLINE_LINUX_DEFAULT="transparent_hugepage=never acpi_enforce_resources=lax apparmor=0 net.ifnames=0 biosdevname=0"
GRUB_CMDLINE_LINUX=""
EOF
update-grub

cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

cat > /etc/modules-load.d/kubernetes.conf <<EOF
br_netfilter
overlay
EOF

modprobe br_netfilter
modprobe overlay

rm /etc/netplan/*.yaml
cat > /etc/netplan/01-netcfg.yaml <<EOF
---
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF

timedatectl set-ntp true
systemctl disable --now apparmor
systemctl enable  --now systemd-timesyncd


# pre install k8s bits
curl  https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.32/deb/Release.key -s | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
cat > /etc/apt/sources.list.d/pkgs_k8s_io_core_stable_v1_32_deb.list <<EOF
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /
EOF

apt -y update
apt -y install \
    containerd \
    kubeadm \
    kubectl \
    kubelet \
    etcd-server \
    etcd-client \
    ;

systemctl disable --now kubelet
systemctl disable --now etcd

mkdir /etc/containerd
containerd config default | sed '/SystemdCgroup/s/false/true/' > /etc/containerd/config.toml
systemctl enable  --now containerd

# handle remaining vagrant bits
mkdir /home/vagrant/.ssh
curl https://raw.githubusercontent.com/hashicorp/vagrant/refs/heads/main/keys/vagrant.pub > /home/vagrant/.ssh/authorized_keys
chown vagrant.vagrant /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys

# clean up
# manual list
# kernel discovery
# -dev discovery
(
cat <<EOF
apparmor
command-not-found
fonts-ubuntu-console
friendly-recovery
grub-legacy-ec2
laptop-detect
libx11-6
libx11-data
libxcb1
libxext6
libxmuu1
motd-news-config
popularity-contest
ppp
pppconfig
pppoeconf
usbutils
xauth
EOF

dpkg --list | awk '{ print $2 }' | egrep 'linux-headers|linux-image-.*-generic|linux-modules-.*-generic|linux-source|-doc$' | grep -v "$(uname -r)"
dpkg --list | awk '{ print $2 }' | grep -- '-dev\(:[a-z0-9]\+\)\?$' | grep -v 'systemd-dev'
) | sort | uniq | xargs apt purge -y

cat <<EOF | cat >> /etc/dpkg/dpkg.cfg.d/excludes
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
EOF

apt-get -y autoremove;
apt-get -y clean;

rm -f /root/.wget-hsts
rm -f /var/lib/systemd/random-seed
rm -rf /lib/firmware/*
rm -rf /tmp/* /var/tmp/*
rm -rf /usr/share/doc/*
rm -rf /usr/share/doc/linux-firmware/*

find /var/cache -type f -delete;
find /var/log -type f -exec truncate --size=0 {} \;

truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id

fstrim -a

export HISTSIZE=0
