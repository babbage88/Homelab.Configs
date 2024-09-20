variable "ssh_keys" {
  description = "List of SSH keys"
  type = list(string)
}


variable "ssh_key" {
    description = "ssh public key to add to authorized on VM"
    type = string
}

variable "proxmox_node" {
  description = "Proxmox Hostname or IP"
  type = string
  default = "proxmox1"
}

variable "proxmox_host" {
    default = "https://vm1.trahan.dev/"
}

variable "template_name" {
    default = "ubuntu-cloudinit-2204"
}

variable "prox_api_id" {
  type = string
}

variable "prox_api_token" {
  type = string
  sensitive = true
}

variable "prox_ssh_user" {
  type = string
  default = "root"
}

variable "prox_user" {
  type = string
  default = "root@pam"
}

variable "prox_pw" {
  type = string
  sensitive = true

}

variable "vm_names" {
  description = "List of VMs to create"
  type = list(string)
  default = ["trahkube1","trahkube2","trahkube3"]
}

variable "db_vm_names_list" {
  description = "List of Database VMs to create"
  type = list(string)
  default = ["trahdb1", "trahdb2"]
}

variable "db_vm_names" {
  description = "Map of Database VMs with their corresponding Proxmox node"
  type = map(object({
    node_name = string
  }))
  default = {
    "trahdb1" = { node_name = "proxmox1" }
    "trahdb2" = { node_name = "proxmox2" }
  }
}

variable "domain_name" {
  type = string
  default = "trahan.dev"
}

variable "laptop_ssh_key" {
  type = string
  description = "SSH public key on surface laptop"
}

variable "vm_pw" {
  type = string
  description = "Password for the user created on vm"
  sensitive = true
}

variable "vm_user" {
  type = string
  default = "jtrahan"
}

variable "vm_memory" {
  type = number
  default = 2048
}

variable "vm_hd_Size" {
  type = number
  default = 25
}

variable "vm_cpu_cores" {
  type = number
  default = 2
}

variable "dns_ip" {
  description = "IP address of Master DNS-Server"
  default = "10.0.0.15"
}
variable "dns_key" {
  description = "name of the DNS-Key to user"
  default = "tsig-key"
}
variable "dns_key_secret" {
  description = "base 64 encoded string"
}

variable "dns_zone" {
  description = "DNS Zone to create recors for each VM"
  default = "trahan.dev."
}

variable "ct-node" {
  type        = string
  default = "proxmox1"
  description = "The node on which to create the container."
}

variable "ct-pool" {
  type        = string
  description = "The pool in which to create the container."
  nullable    = true
  default     = "terraform-containers"
}

variable "ct-start" {
  type = object({
    on-deploy  = bool
    on-boot    = bool
    order      = optional(number)
    up-delay   = optional(number)
    down-delay = optional(number)
  })
  description = "The start settings for the container."
  default = {
    on-deploy  = true
    on-boot    = false
    order      = 0
    up-delay   = 0
    down-delay = 0
  }
}

variable "ct-unprivileged" {
  type        = bool
  description = "Whether the container should be unprivileged."
  default     = true
}

variable "ct-id" {
  type        = number
  description = "The ID of the container."
  default     = null
}

variable "ct-cpu" {
  type = object({
    arch  = optional(string)
    cores = optional(number)
    units = optional(string)
  })
  description = "Container CPU configuration."
  default     = {
    cores = 2
  }
}

variable "ct-mem" {
  type = object({
    dedicated = optional(number)
    swap      = optional(number)
  })
  description = "Container memory configuration."
  default     = {
    dedicated = 1024
    swap = 1024
  }
}

variable "ct-disk" {
  type = object({
    datastore = optional(string)
    size      = optional(number)
  })
  description = "Container storage."
  default     = {
    datastore = "storageprox"
    size = 90
  }
}

variable "ct-disks" {
  type = map(object({
    datastore = optional(string)
    size      = optional(number)
  }))
  description = "Container storage."
  default = {
    disk0 = { datastore = "local-lvm"
      size = 25
    }

    disk1 = { datastore = "storageprox" 
      size = 100
    }
  }
}

variable "ct-net-ifaces" {
  type = map(object({
    name        = optional(string)
    bridge      = optional(string)
    enabled     = optional(bool)
    firewall    = optional(bool)
    mac_address = optional(string)
    mtu         = optional(number)
    rate_limit  = optional(string)
    vlan_id     = optional(number)
    ipv4_addr   = optional(string)
    ipv4_gw     = optional(string)
    ipv6_addr   = optional(string)
    ipv6_gw     = optional(string)
  }))
  description = "Container network interfaces."
  default = {
    eth0 = {    
      name = "eth0"
      bridge = "vmbr0"
      enabled = true
      firewall = false
      ipv4_addr = "dhcp"}
  }
}

variable "clone-target" {
  type = map(object({
    vm_id        = optional(string)
    node_name    = optional(string)
    datastore_id = optional(string)
  }))
  description = "The target container to clone."
  nullable    = true
  default     = {}
}

variable "ct-os" {
  type        = string
  description = "The template to use for the container."
  default     = "trahan-nas-backups:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

variable "ct-os-type" {
  type        = string
  description = "The type of the OS template. Unmanaged means PVE won't manage the container (e.g. static IPs don't get auto assigned)"
  default     = "ubuntu"
}

variable "ct-os-upload" {
  type = object({
    datastore           = optional(string)
    source              = optional(string)
    checksum            = optional(string)
    checksum_alg        = optional(string)
    decomp_alg          = optional(string)
    file_name           = optional(string)
    overwrite           = optional(bool)
    overwrite_unmanaged = optional(bool)
    timeout             = optional(number)
    verify              = optional(bool)
  })
  description = "Settings for uploading the OS template."
  default     = {}
}

variable "ct-console" {
  type = object({
    enabled   = optional(bool)
    type      = optional(string)
    tty_count = optional(number)
  })
  description = "Console settings for the container."
  nullable    = true
  default = {
    enabled = true
    type    = "shell"
  }
}

variable "ctinit" {
  type = object({
    hostname  = optional(string)
    root_pw   = optional(string)
    root_keys = optional(list(string))
  })
  description = "Initialization settings for the container."
  default     = {}
}

variable "ct-dns" {
  type = object({
    domain  = optional(string)
    servers = optional(list(string))
  })
  description = "DNS settings for the container. Map should contain maximum 1 object. Defined as map because empty dns block triggers a provider error."
  default     = {
    domain = "trahan.dev"
    servers = [ "10.0.0.15", "10.0.0.64" ]
  }
}

variable "ct-tags" {
  type        = list(string)
  description = "The tags to apply to the container."
  default     = []
}

variable "ct-features" {
  type = object({
    nesting = optional(bool)
    fuse    = optional(bool)
    keyctl  = optional(bool)
    mount   = optional(list(string))
  })
  description = "Features to enable for the container."
  nullable    = true
  default = {
    nesting = true
  }
}

variable "ct-template" {
  type        = bool
  description = "Whether the container is a template."
  default     = false
}

variable "ct-fw" {
  type = object({
    enabled       = optional(bool)
    dhcp          = optional(bool)
    input_policy  = optional(string)
    output_policy = optional(string)
    log_level_in  = optional(string)
    log_level_out = optional(string)
    macfilter     = optional(bool)
    ipfilter      = optional(bool)
    ndp           = optional(bool)
    radv          = optional(bool)
  })
  description = "Firewall settings for the container."
  default     = {}
}

variable "ct-fw-rules" {
  type = map(object({
    enabled   = optional(bool)
    action    = string
    direction = string
    sourceip  = optional(string)
    destip    = optional(string)
    sport     = optional(string)
    dport     = optional(string)
    proto     = optional(string)
    log       = optional(string)
    comment   = optional(string)
  }))
  description = "Firewall rules for the container."
  default     = {}
}

variable "ct-fw-fsg" {
  type = map(object({
    enabled = optional(bool)
    iface   = optional(string)
    comment = optional(string)
  }))
  description = "Firewall rules that import from a security group."
  default     = {}
}

variable "ct-ssh-privkey" {
  type        = string
  description = "File containing ssh private key to be used for container bootstrap."
  default     = "~/.ssh/id_rsa"
}

variable "ct-bootstrap-script" {
  type        = string
  description = "Path to script file ro run on container creation."
  default     = null
}

variable "reverse_dns_zone" {
  type        = string
  description = "The reverse DNS zone, e.g., 113.0.203.in-addr.arpa."
  default     = "1.0.10.in-addr.arpa."  # Example, ensure this is correct
}

variable "b2_key" {
  type = string
  description = "B2 app key ID"
}

variable "b2_secret" {
  type = string
  description = "B2 App Key Secret"
  sensitive = true
}