terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.62.0"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint  = var.proxmox_host
  api_token = "${var.PROX_API_ID}=${var.PROX_API_TOKEN}"
  insecure = true
  ssh {
    username = var.prox_user
    agent       = false
    private_key = file("~/.ssh/id_rsa")
  }
}

data "local_file" "ssh_public_key" {
  filename = "./id_rsa.pub"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox2"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}
    manage_etc_hosts: true
    fqdn: ${var.vm_name}.${var.domain_name}
    user: ${var.vm_user}
    password: ${var.vm_pw}
    ssh_authorized_keys:
      - ${trimspace(data.local_file.ssh_public_key.content)}
      - ${var.laptop_ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
    chpasswd:
      expire: False
    users:
      - default
    package_upgrade: true
    packages:
      - curl
      - wget
      - jq
      - git
      - vim
      - net-tools
      - python-is-python3
      - dotnet-sdk-8.0
    runcmd:
      - mkdir /gotmp
      - [wget, "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz", -O, /gotmp/go.tar.gz]
      - [tar, -xzvf, /gotmp/go.tar.gz, -C, /usr/local]
      - [bash, -c, "echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/jtrahan/.bashrc"]
    EOF

    file_name = "cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name      = var.vm_name
  node_name = "proxmox2"

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/jammy-server-cloudimg-amd64.img"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

output "vm_ipv4_address" {
  value = proxmox_virtual_environment_vm.ubuntu_vm.ipv4_addresses[1][0]
}