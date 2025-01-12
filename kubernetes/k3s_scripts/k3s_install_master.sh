#!/bin/bash
export NODE_IP='10.0.0.201'
export EXTERNAL_IP='10.0.0.65'
export CONN_STR='"postgres://k3suser:Example1@db.trahan.dev:5432/k3s"'
export TOKEN='tvercgfcgfcgfcgcgfccgffc'
export K3S_ARGS=\'--token=$TOKEN\ --node-ip=$NODE_IP\ --kube-apiserver-arg=kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname\ --node-external-ip=$EXTERNAL_IP\ --datastore-endpoint=$CONN_STR\'
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC=$K3S_ARGS sh -