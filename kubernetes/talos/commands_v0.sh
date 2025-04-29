#!/bin/bash
#rm -rf rendered/
#rm -rf ~/.talos/config

talosctl gen config trahan-cluster https://10.0.0.70:6443 \
  --with-secrets secrets.yaml \
  --config-patch @patches/allow-controlplane-workloads.yaml \
  --config-patch @patches/cni.yaml \
  --config-patch @patches/dhcp.yaml \
  --config-patch @patches/install-disk.yaml \
  --config-patch @patches/interface-names.yaml \
  --config-patch @patches/kubelet-certificates.yaml \
  --config-patch @patches/pod-security.yaml \
  --config-patch @patches/extra-disk-mounts.yaml \
  --config-patch-control-plane @patches/vip.yaml \
  --output rendered2/.

talosctl apply -f rendered/controlplane.yaml -n 10.0.1.71 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.72 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.73 --insecure
talosctl apply -f rendered/controlplane2.yaml -n 10.0.1.74 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.84 --insecure

#talosctl apply -f renderedv2-onedisk/controlplane4.yaml -n 10.0.1.84 --insecure


talosctl patch mc --nodes 10.0.1.84 --patch @./patches/extra-disk-mount.yaml


mkdir -p ~/.talos
cp rendered/talosconfig ~/.talos/config

talosctl config endpoint 10.0.1.71 10.0.1.72 10.0.1.73 10.0.1.74
talosctl config node 10.0.1.71

sleep 90
talosctl bootstrap -n taloskube1

sleep 120
helm -n monitoring upgrade --create-namespace --install kube-prometheus-stack prometheus-community/kube-prometheus-stack  \
 -f values-prometheus.yaml

helm upgrade --install --create-namespace -n ingress-nginx ingress-nginx ingress-nginx/ingress-nginx --values v1.11_ingx_values.yaml

kubectl  patch -n ingress-nginx services ingress-nginx-controller -p '{"spec":{"externalIPs":["10.0.0.70", "10.0.1.73", "10.0.1.71","10.0.1.72, "10.0.1.84"]}}'

kubectl apply --server-side --force-conflicts -f  https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.25.0/cnpg-1.25.0.yaml