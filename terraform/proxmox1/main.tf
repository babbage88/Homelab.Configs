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
  #api_token = "${var.prox_api_id}=${var.prox_api_token}"
  username = "root@pam"
  password = var.prox_pw
  insecure  = true
  ssh {
    username    = "root"
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

resource "random_password" "ct_root_pw" {
  count  = var.ctinit.root_pw == null ? 1 : 0
  length = 26
}

resource "proxmox_virtual_environment_container" "ct" {
  description   = "Managed by Terraform"
  node_name     = var.ct-node
  pool_id       = var.ct-pool
  started       = var.ct-start.on-deploy
  start_on_boot = var.ct-start.on-boot

  startup {
    order      = var.ct-start.order
    up_delay   = var.ct-start.up-delay
    down_delay = var.ct-start.down-delay
  }
  unprivileged = var.ct-unprivileged
  vm_id        = var.ct-id

  cpu {
    architecture = var.ct-cpu.arch
    cores        = var.ct-cpu.cores
    units        = var.ct-cpu.units
  }

  memory {
    dedicated = var.ct-mem.dedicated
    swap      = var.ct-mem.swap
  }

  disk {
    datastore_id = var.ct-disk.datastore
    size         = var.ct-disk.size
  }

  dynamic "network_interface" {
    for_each = var.ct-net-ifaces
    content {
      name        = network_interface.value.name
      bridge      = network_interface.value.bridge
      enabled     = network_interface.value.enabled
      firewall    = network_interface.value.firewall
      mac_address = network_interface.value.mac_address
      mtu         = network_interface.value.mtu
      rate_limit  = network_interface.value.rate_limit
      vlan_id     = network_interface.value.vlan_id
    }
  }

  dynamic "clone" {
    for_each = var.clone-target
    content {
      vm_id        = clone.value.vm_id
      node_name    = clone.value.node_name
      datastore_id = clone.value.datastore
    }
  }

  operating_system {
    template_file_id = var.ct-os
    type             = var.ct-os-type
  }

  console {
    enabled   = var.ct-console.enabled
    type      = var.ct-console.type
    tty_count = var.ct-console.tty_count
  }

  initialization {
    hostname = var.ctinit.hostname
    dynamic "dns" {
      for_each = var.ct-dns != null ? [1] : []

      content {
        domain  = var.ct-dns.domain
        servers = var.ct-dns.servers
      }
    }
    dynamic "ip_config" {
      for_each = var.ct-net-ifaces
      content {
        ipv4 {
          address = ip_config.value.ipv4_addr
          gateway = ip_config.value.ipv4_gw
        }
        ipv6 {
          address = ip_config.value.ipv6_addr
          gateway = ip_config.value.ipv6_gw
        }
      }
    }
    user_account {
      password = var.ctinit.root_pw != null ? var.ctinit.root_pw : random_password.ct_root_pw[0].result
      keys     = var.ctinit.root_keys
    }
  }

  dynamic "features" {
    for_each = var.ct-features != null ? [1] : []

    content {
      nesting = try(var.ct-features.nesting, true)
      fuse    = var.ct-features.fuse
      keyctl  = var.ct-features.keyctl
      mount   = var.ct-features.mount
    }
  }

  template = var.ct-template
  tags     = var.ct-tags

  lifecycle {
    precondition {
      condition     = (var.ct-os == null && var.ct-os-upload.source != null) || (var.ct-os-upload.source == null && var.ct-os != null)
      error_message = "Variables 'ct-os' and 'ct-os-upload' are mutually exclusive!"
    }
  }
}


resource "local_file" "init" {
  content = templatefile("cloud-init-lxc.tpl",
           {
              lxc_user = "${var.vm_user}"
              lxc_pw = "${var.vm_pw}"
              lxc_ssh_key = "${var.ssh_key}"
           })

          filename = "99-mydata.cfg"
  }
resource "time_sleep" "wait_for_ct" {
  count = var.ct-bootstrap-script == null ? 0 : 1
  create_duration = "10s"
  triggers = {
    vmid = proxmox_virtual_environment_container.ct.vm_id
  }
  depends_on = [
    proxmox_virtual_environment_container.ct
  ]
}

resource "terraform_data" "bootstrap_ct" {
  count = var.ct-bootstrap-script == null ? 0 : 1

  connection {
    type  = "ssh"
    host  = replace(proxmox_virtual_environment_container.ct.initialization[0].ip_config[0].ipv4[0].address, "/23", "")
    user  = "root"
    agent = false 
    private_key = file(var.ct-ssh-privkey)
  }
  provisioner "remote-exec" {
    inline = [ "apt update && apt install -y vim cloud-init" ]
  }

  provisioner "file" {
    source      = resource.local_file.init.filename
    destination = "/etc/cloud/cloud.cfg.d/${resource.local_file.init.filename}"
  }

  provisioner "remote-exec" {
    inline = [  "cloud-init init --local",
                "cloud-init init",
                "cloud-init modules --mode=config",
                "cloud-init modules --mode=final",
                "cloud-init status --wait --long" ]
    on_failure = continue
  }

  triggers_replace = [
    time_sleep.wait_for_ct[0].id
  ]

  depends_on = [
    time_sleep.wait_for_ct
  ]
}

resource "proxmox_virtual_environment_file" "cloud_config" {
  for_each    = { for db_vm_name in var.db_vm_names : db_vm_name => db_vm_name }
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.proxmox_node

  source_raw {
  data = <<-EOF
  #cloud-config
  hostname: ${each.value}
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
    - postgresql
  runcmd:
    - mkdir /gotmp
    - [wget, "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz", -O, /gotmp/go.tar.gz]
    - [tar, -xzvf, /gotmp/go.tar.gz, -C, /usr/local]
    - [bash, -c, "echo 'export PATH=/usr/local/go/bin:$PATH' >> /home/${var.vm_user}/.bashrc"]
    - apt install -y qemu-guest-agent && systemctl start qemu-guest-agent
  EOF

    file_name = "${each.value}_cloud-config-pg.yml"
  }
}

resource "proxmox_virtual_environment_vm" "pgdb_vm" {
  for_each   = { for db_vm_name in var.db_vm_names : db_vm_name => db_vm_name }
  name      = each.value
  node_name = var.proxmox_node

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
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
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

    user_data_file_id = proxmox_virtual_environment_file.cloud_config[each.key].id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.proxmox_node
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

resource "dns_a_record_set" "vms" {
  for_each  = { for vm in proxmox_virtual_environment_vm.pgdb_vm : vm.name => vm.ipv4_addresses[1][0] }
  zone      = var.dns_zone
  name      = each.key
  addresses = [each.value]
  ttl       = 300

  depends_on = [proxmox_virtual_environment_vm.pgdb_vm]  # Ensures that the VM creation completes
}

resource "dns_a_record_set" "ct_a_record" {
  zone    = var.dns_zone
  name    = proxmox_virtual_environment_container.ct.initialization[0].hostname
  ttl     = 300
  addresses =  [replace(proxmox_virtual_environment_container.ct.initialization[0].ip_config[0].ipv4[0].address, "/23", "")]

  depends_on = [ proxmox_virtual_environment_container.ct ]
}

output "ct_ip_info" {
  value = { 
    hostname = proxmox_virtual_environment_container.ct.initialization[0].hostname, 
    ipaddr = proxmox_virtual_environment_container.ct.initialization[0].ip_config[0].ipv4[0].address
  }
}

output "vm_ipv4_addresses" {
  value = { for vm in proxmox_virtual_environment_vm.pgdb_vm : vm.name => vm.ipv4_addresses[1][0] }
}

