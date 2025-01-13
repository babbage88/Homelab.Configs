#!/bin/bash
helm upgrade --install --create-namespace \
--repo "https://starttoaster.github.io/proxmox-exporter" 
-n monitoring \
--values ./values.yaml \
proxmox-exporter \
proxmox-exporter