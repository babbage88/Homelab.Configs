export TOKEN='verHK9CY8TqULBb1j1dfva33134'

#uninstall agent
#/usr/local/bin/k3s-agent-uninstall.sh
curl -sfL https://get.k3s.io | K3S_URL=https://kubeapi.trahan.dev:6443 K3S_TOKEN=$TOKEN sh -