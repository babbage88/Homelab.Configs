IMAGE_USER=jtrahan
SSH_PUB_KEY_PATH=/mnt/pve/proxbkup/id_rsa_lap.pub
GO_DOWNLOAD_PATH=/home/devops/go.tar.gz

#Verify wget is instlled
sudo apt install wget

#download latest ubuntu server image
wget --progress=dot -q https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img --show-progress

# Install libguestfs-tools, used to cutomize image
sudo apt update -y && sudo apt install libguestfs-tools -y

# Install qemu guest agent on image/template and enable the service
sudo virt-customize -a noble-server-cloudimg-amd64.img --install curl,wget,jq,git,dotnet-sdk-8.0 

sudo virt-customize -a noble-server-cloudimg-amd64.img --install qemu-guest-agent --run-command 'systemctl enable qemu-guest-agent.service'

# Create user and configure and add ssh key as authorized
sudo virt-customize -a noble-server-cloudimg-amd64.img --run-command "useradd ${IMAGE_USER}"
sudo virt-customize -a noble-server-cloudimg-amd64.img --run-command "mkdir -p /home/${IMAGE_USER}/.ssh"

# Assumes the public key being added is in the current directory, can also pass full path
sudo virt-customize -a noble-server-cloudimg-amd64.img --ssh-inject ${IMAGE_USER}:file:${SSH_PUB_KEY_PATH-id_rsa_lap.pub} 
sudo virt-customize -a noble-server-cloudimg-amd64.img --run-command "chown -R ${IMAGE_USER}:${IMAGE_USER} /home/${IMAGE_USER}"

## Download go binary on host then copy to image, since name resolution inside libguestfs-tools isn't the best...
wget https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -O ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz}
sudo virt-copy-in -a noble-server-cloudimg-amd64.img ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz} ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz}

## Extract go bin from tar
sudo virt-customize -a noble-server-cloudimg-amd64.img --run-command "tar -xzvf ${GO_DOWNLOAD_PATH-/tmp/go.tar.gz} -C /usr/local"

## Create vm from image
qm create 9000 --memory 2048 --core 2 --name ubuntu-template --net0 virtio,bridge=vmbr0

# Import the downloaded Ubuntu disk to the correct storage
qm importdisk 9000 noble-server-cloudimg-amd64.img local-lvm

# connect disk to vm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0

#add serial console to vm
qm set 9000 --serial0 socket --vga serial0

# enable guest agent
qm set 9000 --agent enabled=1

#convert to template
qm template 9000




