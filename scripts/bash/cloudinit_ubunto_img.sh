#!/bin/bash

export IMAGE_USER=jtrahan
export IMGAGE_DOWNLOAD_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
export SSH_PUB_KEY_PATH="/mnt/pve/proxbkup/id_rsa_lap.pub"
export GO_DOWNLOAD_PATH="/home/jtrahan/go.tar.gz"
export VM_ID=9002

#Verify wget is instlled
sudo apt install wget

#download latest ubuntu server image
wget --progress=dot -q ${IMAGE_DOWNLOAD_URL-https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img} --show-progress

# Install libguestfs-tools, used to cutomize image
sudo apt update -y && sudo apt install libguestfs-tools -y

# Expand image size
qemu-img resize ${IMAGE_NAME-noble-server-cloudimg-amd64.img} +32G

# Install qemu guest agent on image/template and enable the service
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --install qemu-guest-agent --run-command 'systemctl enable qemu-guest-agent.service'
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --install curl,wget,jq,git,dotnet-sdk-8.0

# Create user and configure and add ssh key as authorized
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --run-command "useradd ${IMAGE_USER}"
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --run-command "mkdir -p /home/${IMAGE_USER}/.ssh"

# Assumes the public key being added is in the current directory, can also pass full path
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --ssh-inject ${IMAGE_USER}:file:${SSH_PUB_KEY_PATH-id_rsa_lap.pub}
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --run-command "chown -R ${IMAGE_USER}:${IMAGE_USER} /home/${IMAGE_USER}"

## Download go binary on host then copy to image, since name resolution inside libguestfs-tools isn't the best...
wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -O ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz}
sudo virt-copy-in -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz} ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz}

## Extract go bin from tar
sudo virt-customize -a ${IMAGE_NAME-noble-server-cloudimg-amd64.img} --run-command "tar -xzvf ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz} -C /usr/local"

## Create vm from image
qm create ${VM_ID-9002} --memory 1024 --core 2 --name ubuntu-template --net0 virtio,bridge=vmbr0

# Import the downloaded Ubuntu disk to the correct storage
qm importdisk ${VM_ID-9002} ${IMAGE_NAME-noble-server-cloudimg-amd64.img} local-lvm

# connect disk to vm
qm set ${VM_ID-9002} --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-${VM_ID-9002}-disk-0
qm set ${VM_ID-9002} --ide2 local-lvm:cloudinit
qm set ${VM_ID-9002} --boot c --bootdisk scsi0

#add serial console to vm
qm set ${VM_ID-9002} --serial0 socket --vga serial0

# enable guest agent
qm set ${VM_ID-9002} --agent enabled=1

#convert to template
qm template ${VM_ID-9002}
