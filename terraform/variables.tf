variable "bw_proxmox_token_id" {
  type        = string
  sensitive   = true
}

variable "bw_proxmox_token_secret" {
  type        = string
  sensitive   = true
}

variable "bw_lxc_root_password" {
  type        = string
  sensitive   = true
}

variable "bw_organization_id" {
  type      = string
  sensitive = true
}

variable "bw_ssh_pub_key2" {
  type      = string
  sensitive = true
}