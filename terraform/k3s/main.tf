terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.62.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.0"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint  = var.proxmox_host
  api_token = "${var.prox_api_id}=${var.prox_api_token}"
  insecure  = true
  ssh {
    username    = var.prox_user
    agent       = false
    private_key = file("~/.ssh/id_rsa")
  }
}

provider "dns" {
  update {
    server        = var.dns_ip
    key_name      = "${var.dns_key}."
    key_algorithm = "hmac-sha256"
    key_secret    = var.dns_key_secret
  }
}

data "local_file" "ssh_public_key" {
  filename = "./id_rsa.pub"
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each    = { for vm_name in var.vm_names : vm_name => vm_name }
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "proxmox2"

  source_raw {
  data = <<-EOF
  #cloud-config
  hostname: ${each.value.vm}
  manage_etc_hosts: true
  fqdn: ${each.value}.${var.domain_name}
  user: ${var.vm_user}
  password: ${var.vm_pw}
  ssh_authorized_keys:
  ${join("\n", [for key in var.ssh_keys : "- ${key}"])}
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
    - [bash, -c, "echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/${var.vm_user}/.bashrc"]
    - apt install -y qemu-guest-agent && systemctl start qemu-guest-agent
  EOF

    file_name = "${each.value}_cloud-config.yml"
  }
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  for_each   = { for vm_name in var.vm_names : vm_name => vm_name }
  name      = each.value
  node_name = "proxmox2"

  agent {
    enabled = true
  }

  cpu {
    cores = var.vm_cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/jammy-server-cloudimg-amd64.img"
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.vm_hd_Size
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "dns_a_record_set" "vms" {
  for_each  = { for vm in proxmox_virtual_environment_vm.ubuntu_vm : vm.name => vm.ipv4_addresses[1][0] }
  zone      = var.dns_zone
  name      = each.key
  addresses = [each.value]
  ttl       = 300

  depends_on = [proxmox_virtual_environment_vm.ubuntu_vm]  # Ensures that the VM creation completes
}

output "vm_ipv4_addresses" {
  value = { for vm in proxmox_virtual_environment_vm.ubuntu_vm : vm.name => vm.ipv4_addresses[1][0] }
}

