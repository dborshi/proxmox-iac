resource "proxmox_virtual_environment_container" "redis_lxc" {
  node_name     = "proxmox"
  vm_id         = 116
  unprivileged  = true
  start_on_boot = true

  initialization {
    hostname = "redis"
    
    ip_config {
      ipv4 {
        address = "10.0.0.16/24"
        gateway = "10.0.0.1"
      }
    }

    user_account {
      password = data.bitwarden-secrets_secret.lxc_root_password.value
      keys     = [data.bitwarden-secrets_secret.ssh_pub_key2.value]
    }

  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
    swap      = 512
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
  }

  disk {
    datastore_id = "local-zfs"
    size         = 20
  }

  mount_point {
    volume       = "nvmepool"
    size         = "20G"
    path         = "/var/lib/redis"
    backup       = true
  }
  
  operating_system {
  type             = "debian"
  template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = false
  }
}