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

variable "vm_names" {
  description = "List of VMs to create"
  type = list(string)
  default = ["trahkube1","trahkube2","trahkube3"]
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