#!/bin/bash
talosctl gen config trahan-cluster https://10.0.0.70:6443 \
  --with-secrets secrets.yaml \
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

talosctl apply -f rendered/controlplane.yaml -n 10.0.1.71 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.72 --insecure

mkdir -p ~/.talos
cp rendered/talosconfig ~/.talos/config

talosctl config endpoint 10.0.1.71 10.0.1.72
talosctl config node 10.0.1.71

sleep 90
talosctl bootstrap -n taloskube1