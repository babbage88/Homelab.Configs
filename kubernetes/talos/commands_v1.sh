#!/bin/bash
talosctl gen config trahan-test-cluster https://10.0.0.90:6443 \
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
  --output rendered/

talosctl apply -f rendered/controlplane.yaml -n 10.0.1.74 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.72 --insecure
talosctl apply -f rendered/controlplane.yaml -n 10.0.1.73 --insecure
talosctl apply -f rendered/worker.yaml -n 10.0.1.84 --insecure

talosctl config endpoint 10.0.1.71, 10.0.1.72, 10.0.1.73, 10.0.1.74 --talosconfig rendered/talosconfig
talosctl config node 10.0.1.74 --talosconfig rendered/talosconfig

talosctl config contexts --talosconfig rendered/talosconfig
talosctl get members-talosconfig rendered/talosconfig

sleep 90
talosctl bootstrap -n taloskube4 --talosconfig rendered/talosconfig
sleep 120

helm --kubeconfig kubeconfig install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.7.2

kubectl --kubeconfig kubeconfig --namespace longhorn-system port-forward --address 0.0.0.0 service/longhorn-frontend 5080:80

helm -n monitoring upgrade --create-namespace --install kube-prometheus-stack prometheus-community/kube-prometheus-stack  \
 -f values-prometheus.yaml

helm upgrade --install --create-namespace -n ingress-nginx ingress-nginx ingress-nginx/ingress-nginx --values v1.11_ingx_values.yaml

kubectl --kubeconfig kubeconfig patch -n ingress-nginx services ingress-nginx-controller -p '{"spec":{"externalIPs":["10.0.0.90", "10.0.1.74", "10.0.1.84"]}}'
kubectl --kubeconfig kubeconfig apply -f config-maps/nginx-dashboard.yaml 

kubectl --kubeconfig kubeconfig apply --server-side --force-conflicts -f  https://github.com/cloudnative-pg/cloudnative-pg/releases/download/v1.25.0/cnpg-1.25.0.yaml