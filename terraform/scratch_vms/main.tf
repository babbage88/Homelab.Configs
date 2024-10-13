terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~>0.57.0"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0"
    }
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint  = var.proxmox_host
  api_token = "${var.prox_api_id}=${var.prox_api_token}"
  insecure  = true
  ## Commands needed to start ssh-agent ##
  # eval `ssh-agent -s`
  # ssh-add
  ssh {
    agent    = true
    username = "devops"
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

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each    = var.tst_vm_names
  content_type = "snippets"
  datastore_id = "local"
  node_name    = each.value.node_name

  source_raw {
  data = <<-EOF
  #cloud-config
  hostname: ${each.key}
  manage_etc_hosts: true
  fqdn: ${each.key}.${var.domain_name}
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
    - python3-pip
    - dotnet-sdk-8.0
    - python3-venv
    - python3-setuptools
  runcmd:
    - mkdir /gotmp
    - [wget, "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz", -O, /gotmp/go.tar.gz]
    - [tar, -xzvf, /gotmp/go.tar.gz, -C, /usr/local]
    - [bash, -c, "echo 'export PATH=/usr/local/bin:/usr/local/go/bin:$PATH' >> /home/${var.vm_user}/.bashrc"]
    - apt install -y qemu-guest-agent && systemctl start qemu-guest-agent
  EOF

    file_name = "${each.value.node_name}_${each.key}_cloud-config.yml"
  }
}


resource "proxmox_virtual_environment_vm" "tst_vm" {
  for_each   = var.tst_vm_names
  name       = each.key
  node_name  = each.value.node_name

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.vm_cpu
    type  = "host"
  }

  memory {
    dedicated = each.value.vm_memory_bytes
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = each.value.template_image_name
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 30
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
  for_each  = { for vm in proxmox_virtual_environment_vm.tst_vm : vm.name => vm.ipv4_addresses[1][0] }
  zone      = var.dns_zone
  name      = each.key
  addresses = [each.value]
  ttl       = 300

  depends_on = [proxmox_virtual_environment_vm.tst_vm]  # Ensures that the VM creation completes
}

output "vm_ipv4_addresses" {
  value = { for vm in proxmox_virtual_environment_vm.tst_vm : vm.name => vm.ipv4_addresses[1][0] }
}

