#wget https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.raw
qm create 9001 --name debian12-cloudinit --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --machine q35
qm set 9001 --scsi0 local-lvm:0,discard=on,ssd=1,format=raw,import-from=/mnt/pve/proxbkup/debian-12-generic-amd64.raw
qm disk resize 9001 scsi0 25G
qm set 9001 --boot order=scsi0
qm set 9001 --cpu host --cores 2 --memory 1024
qm set 9001 --bios ovmf --efidisk0 local-lvm:1,format=raw,efitype=4m,pre-enrolled-keys=1
qm set 9001 --ide2 local-lvm:cloudinit
qm set 9001 --agent enabled=1
qm template 9001

