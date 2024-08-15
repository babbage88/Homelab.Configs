variable "ssh_key" {
}

variable "proxmox_host" {
    default = "proxmox2"
}

variable "template_name" {
    default = "ubuntu-cloudinit-2204"
}

variable "PROX_API_ID" {
  type = string
}

variable "PROX_API_TOKEN" {
  type = string
  sensitive = true
}