#!/bin/bash
helm upgrade --install --create-namespace proxmox-exporter \
    --repo "https://starttoaster.github.io/proxmox-exporter" \ 
    --namespace monitoring --values values.yaml proxmox-exporter