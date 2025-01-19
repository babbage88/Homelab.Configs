#!/bin/bash
talosctl gen config trahan-cluster https://10.0.0.70:6443 \
  --with-secrets secrets.yaml \
  --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.2 \
  --config-patch @patches/allow-controlplane-workloads.yaml \
  --config-patch @patches/cni.yaml \
  --config-patch @patches/dhcp.yaml \
  --config-patch @patches/install-disk.yaml \
  --config-patch @patches/interface-names.yaml \
  --config-patch @patches/kubelet-certificates.yaml \
  --config-patch @patches/pod-security.yaml \
  --config-patch @patches/extra-mounts.yaml \
  --config-patch-control-plane @patches/vip.yaml \
  --output rendered/

sleep 60
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.71 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.72 --insecure

sleep 120
mkdir -p ~/.talos
cp rendered/talosconfig ~/.talos/config

talosctl config endpoint 10.0.1.71 10.0.1.72
talosctl config node 10.0.1.71
talosctl bootstrap -n taloskube1