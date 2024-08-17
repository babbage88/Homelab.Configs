variable "ssh_key" {
    default = "ssh-rsa PRB36RJ1234= user@exmple.com"
}

variable "proxmox_host" {
    default = "https://vm2.exsmple.com/"
}

variable "template_name" {
    default = "ubuntu-cloudinit-2204"
}

variable "PROX_API_ID" {
  type = string
  default = "root@pam!terraformFull"
}

variable "PROX_API_TOKEN" {
  type = string
  sensitive = true
}

variable "prox_user" {
  type = string
  default = "root"
}

variable "vm_name" {
  type = string
  default = "trahkube" 
}

variable "domain_name" {
  type = string
  default = "example.com"
}

variable "laptop_ssh_key" {
  type = string
  default = "ssh-rsa 124356= user@laptop.example.com"
}

variable "vm_pw" {
  type = string
  default = "$5$/4535345435Oumbgkbmnf0Lfdbgfbgghneujngeuitrjgnserjign"
  sensitive = true
}

variable "vm_user" {
  type = string
  default = "devops"
}