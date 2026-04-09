terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.100.0"
    }
    bitwarden-secrets = {
      source  = "bitwarden/bitwarden-secrets"
      version = "0.5.4-pre"
    }
  }
}

provider "bitwarden-secrets" {
    api_url         = "https://vault.bitwarden.eu/api"
    identity_url    = "https://vault.bitwarden.eu/identity"
    organization_id = var.bw_organization_id
}

provider "proxmox" {
  endpoint  = "https://10.0.0.10:8006/"
  api_token = "${data.bitwarden-secrets_secret.pve_token_id.value}=${data.bitwarden-secrets_secret.pve_token_secret.value}"
  insecure  = true
  ssh {
    username    = "user"
    private_key = file("~/.ssh/id_key1")
  }
}