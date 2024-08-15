#!/bin/bash
# Create the instance
qm create ${VM_ID-9000} -name ubuntu-cloudinit-2204 -memory 1024 -net0 virtio,bridge=vmbr0 -cores 1 -sockets 1

# Import the OpenStack disk image to Proxmox storage
qm importdisk ${VM_ID-9000} jammy-server-cloudimg-amd64.img local-lvm

# Attach the disk to the virtual machine
qm set ${VM_ID-9000} -scsihw virtio-scsi-pci -virtio0 local-lvm:vm-${VM_ID-9000}-disk-0

# Add a serial output
qm set ${VM_ID-9000} -serial0 socket

# Set the bootdisk to the imported Openstack disk
qm set ${VM_ID-9000} -boot c -bootdisk virtio0

# Enable the Qemu agent
qm set ${VM_ID-9000} -agent 1

# Allow hotplugging of network, USB and disks
qm set ${VM_ID-9000} -hotplug disk,network,usb

# Add a single vCPU (for now)
qm set ${VM_ID-9000} -vcpus 1

# Add a video output
qm set ${VM_ID-9000} -vga qxl

# Set a second hard drive, using the inbuilt cloudinit drive
qm set ${VM_ID-9000} -ide2 local-lvm:cloudinit

# Resize the primary boot disk (otherwise it will be around 2G by default)
# This step adds another 8G of disk space, but change this as you need to
#qm resize ${VM_ID-9000} virtio0 +8G

qm set ${VM_ID-9000} --cicustom "user=local:snippets/user.yml,network=local:snippets/network.yml"

# Convert the VM to the template
qm template ${VM_ID-9000}
