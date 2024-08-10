#!/bin/bash

VM_ID=9000

#wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.raw
wget ${IMAGE_URL-https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.raw}
qm create ${VM_ID} --name ${VM_TMPLT_NAME-debian12-cloudinit} --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --machine q35
qm set ${VM_ID} --scsi0 local-lvm:0,discard=on,ssd=1,format=raw,import-from=${IMG_DIR-/mnt/pve/proxbkup/}${IMAGE_NAME-debian-12-generic-amd64.raw}
qm disk resize ${VM_ID} scsi0 25G
qm set ${VM_ID} --boot order=scsi0
qm set ${VM_ID} --cpu host --cores 2 --memory 1024
qm set ${VM_ID} --bios ovmf --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1
qm set ${VM_ID} --ide2 local-lvm:cloudinit
qm set ${VM_ID} --agent enabled=1
qm template ${VM_ID}

