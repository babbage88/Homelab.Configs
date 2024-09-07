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
    inline = [  "systemctl enable cloud-init",
                "systemctl restart cloud-init",
                "reboot" ]
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
  for_each    = var.db_vm_names
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
    - mkdir /pgdumps
    - chown -R jtrahan:jtrahan /pgdumps && chmod -R 770 /pgdumps
    - python -m venv /pgdumps/venv
    - source /pgdumps/venv/bin/activate && pip3 install b2 && b2 account authorize ${var.b2_key} ${var.b2_secret}
    - [wget, "https://go.dev/dl/go1.23.0.linux-amd64.tar.gz", -O, /gotmp/go.tar.gz]
    - [tar, -xzvf, /gotmp/go.tar.gz, -C, /usr/local]
    - pip3 install b2
    - b2 account authorize ${var.b2_key} ${var.b2_secret}
    - [bash, -c, "echo 'export PATH=/usr/local/bin:/usr/local/go/bin:$PATH' >> /home/${var.vm_user}/.bashrc"]
    - apt install -y qemu-guest-agent && systemctl start qemu-guest-agent
  EOF

    file_name = "${each.value.node_name}_cloud-config.yml"
  } 
}


resource "proxmox_virtual_environment_vm" "pgdb_vm" {
  for_each   = var.db_vm_names
  name       = each.key
  node_name  = each.value.node_name

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

resource "dns_a_record_set" "vms" {
  for_each  = { for vm in proxmox_virtual_environment_vm.pgdb_vm : vm.name => vm.ipv4_addresses[1][0] }
  zone      = var.dns_zone
  name      = each.key
  addresses = [each.value]
  ttl       = 300

  depends_on = [proxmox_virtual_environment_vm.pgdb_vm]  # Ensures that the VM creation completes
}

locals {
  reverse_ip = {
    for vm in proxmox_virtual_environment_vm.pgdb_vm :
    vm.name => element(reverse(split(".", vm.ipv4_addresses[1][0])), 0)
  }
}


resource "dns_ptr_record" "vms" {
  for_each = proxmox_virtual_environment_vm.pgdb_vm

  zone = var.reverse_dns_zone  # Specify the reverse DNS zone (should be fully qualified)
  name = "${local.reverse_ip[each.key]}" # Use the calculated reverse IP
  ptr  = "${each.key}.${var.domain_name}."  # The corresponding FQDN for the PTR record, add trailing dot
  ttl  = 300
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

