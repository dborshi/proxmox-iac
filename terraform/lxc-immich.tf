resource "proxmox_virtual_environment_container" "immich_lxc" {
  node_name     = "proxmox"
  vm_id         = 150
  unprivileged  = true
  start_on_boot = true

  initialization {
    hostname = "immich"

    ip_config {
      ipv4 {
        address = "10.0.0.50/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      password = data.bitwarden-secrets_secret.lxc_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
    swap      = 2048
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 32
  }

  mount_point {
    volume  = "datapool"
    size    = "400G"
    path    = "/mnt/immich"
    backup  = true
  }

  operating_system {
    type             = "debian"
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }
}