#!/bin/bash
pct create 115 local:vztmpl/archlinux-base_20240911-1_amd64.tar.zst --cores 2 --memory 2048 --swap 2048  --rootfs local-lvm:15  --hostname trahdev2 --net0 name=eth0,firewall=0,ip=dhcp,ip6=dhcp,bridge=vmbr0,type=veth,hwaddr=32:e4:68:71:43:88 --ssh-public-keys /root/.ssh/authorized_keys --unprivileged 1 --password ${CT_PW}


#pct create 115 local:vztmpl/archlinux-base_20240911-1_amd64.tar.zst --cores 2 \ 
#  --memory 2048 --swap 2048  --rootfs local-lvm:15  --hostname trahdev2 \
#	--net0 name=eth0,firewall=0,ip=dhcp,ip6=dhcp,bridge=vmbr0,type=veth,hwaddr=32:e4:68:71:43:88 \
#  --ssh-public-keys /root/.ssh/authorized_keys --unprivileged 1 --password ${CT_PW}


#pct create 117 local:vztmpl/archlinux-base_20240911-1_amd64.tar.zst --hostname gal1 --memory 1024 --net0 name=eth0,bridge=vmbr0,firewall=1,gw=192.168.10.1,ip=192.168.10.71/24,tag=10,type=veth \
#  --storage localblock --rootfs localblock:8 --unprivileged 1 --pool Containers --ignore-unpack-errors --ssh-public-keys /root/.ssh/authorized_keys --ostype ubuntu --password="$ROOTPASS" --start 1

