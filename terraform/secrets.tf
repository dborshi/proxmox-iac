data "bitwarden-secrets_secret" "pve_token_id" {
    id = var.bw_proxmox_token_id
}

data "bitwarden-secrets_secret" "pve_token_secret" {
    id = var.bw_proxmox_token_secret
}

data "bitwarden-secrets_secret" "lxc_root_password" {
    id = var.bw_lxc_root_password
}

data "bitwarden-secrets_secret" "ssh_pub_key2" {
    id = var.bw_ssh_pub_key2
}