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

variable "prox_ssh_user" {
  type = string
  default = "root"
}

variable "prox_user" {
  type = string
  default = "devops"
}

variable "prox_pw" {
  type = string
  sensitive = true

}

variable "vm_names" {
  description = "List of VMs to create"
  type = list(string)
  default = ["trah-rt-01"]
}

variable "rtr_vm_names_list" {
  description = "List of tailscale subnet router VMs to create"
  type = list(string)
  default = ["trah-rt-01"]
}

variable "rtr_vm_names" {
  description = "Map of TS Router VMs with their corresponding Proxmox node"
  type = map(object({
    node_name = string
  }))
  default = {
    "trah-rt-01" = { node_name = "proxmox2" }
    "trah-rt-02" = { node_name = "proxmox1" }
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

variable "b2_key" {
  type = string
  description = "B2 app key ID"
}

variable "b2_secret" {
  type = string
  description = "B2 App Key Secret"
  sensitive = true
}