#!/bin/bash
apt update && apt upgrade -y 
apt install -y curl wget jq git vim net-tools python-is-python3 dotnet-sdk-8.0 apt-cacher-ng nginx
useradd -m ${USERNAME-jtrahan}
echo "${USERNAME-jtrahan}:$1" | chpasswd
passwd --expire ${USERNAME}
usermod -a -G sudo ${USERNAME-jtrahan}
wget "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz" -O /tmp/go.tar.gz
tar -xzvf /tmp/go.tar.gz -C /usr/local
echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/${USERNAME-jtrahan}/.bashrc
mkdir /home/${USERNAME-jtrahan}/projects
git clone https://github.com/babbage88/go-infra.git /home/${USERNAME-jtrahan}/projects
chown -R ${USERNAME-jtrahan}:${USERNAME-jtrahan} /home/${USERNAME-jtrahan}/projects


