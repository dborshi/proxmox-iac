resource "proxmox_virtual_environment_container" "tailscale_lxc" {
  node_name     = "proxmox"
  vm_id         = 121
  unprivileged  = true
  start_on_boot = true

  initialization {
    hostname = "tailscale"

    ip_config {
      ipv4 {
        address = "10.0.0.21/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      password = data.bitwarden-secrets_secret.lxc_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 4
  }

  operating_system {
    type             = "debian"
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}
