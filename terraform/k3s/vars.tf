variable "ssh_keys" {
  description = "List of SSH keys"
  type = list(string)
}


variable "ssh_key" {
    description = "ssh public key to add to authorized on VM"
    type = string
}

variable "proxmox_host" {
    default = "https://vm2.trahan.dev/"
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

variable "prox_user" {
  type = string
  default = "root"
}

variable "k3s_vm_names" {
  description = "Map of Database VMs with their corresponding Proxmox node"
  type = map(object({
    node_name = string
    vm_memory = number

  }))
  default = {
    "trahkube1" = { node_name = "proxmox1", vm_memory = 4096 }
    "trahkube2" = { node_name = "proxmox2", vm_memory = 3072 }
    "trahkube3" = { node_name = "proxmox2", vm_memory = 3072 }
  }
}

variable "internal_services_a_records" {
  description = "Map of Database VMs with their corresponding Proxmox node"
  type = map(object({
    dns_name = string
    ip_addr = string
    zone = string
  }))
  default = {
    "goinfra" = { dns_name = "infra", ip_addr = "10.0.1.64", zone = "trahan.dev." }
    "traefikdb" = { dns_name = "traefik", ip_addr = "10.0.1.64", zone = "trahan.dev." }
    "prometh" = { dns_name = "prometheus", ip_addr = "10.0.1.64", zone = "trahan.dev." }
    "calc" = { dns_name = "calc", ip_addr = "10.0.1.64", zone = "test.trahan.dev." }
    "api" = { dns_name = "api", ip_addr = "10.0.1.64", zone = "test.trahan.dev." }
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

variable "reverse_dns_zone" {
  type        = string
  description = "The reverse DNS zone, e.g., 113.0.203.in-addr.arpa."
  default     = "1.0.10.in-addr.arpa."  # Example, ensure this is correct
}