resource "proxmox_virtual_environment_container" "immich_lxc" {
  node_name     = "proxmox"
  vm_id         = 150
  unprivileged  = true
  start_on_boot = false
  protection    = true

  startup {
    down_delay = -1
    order      = 5
    up_delay   = -1
  }


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

  operating_system {
    type             = "debian"
    template_file_id = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  }

  features {
    nesting = true
  }

  mount_point {
    volume  = "datapool"
    size    = "400G"
    path    = "/mnt/immich"
    backup  = true
  }

  device_passthrough {
    deny_write = false
    gid        = 992
    mode       = "0660"
    path       = "/dev/dri/by-path/pci-0000:09:00.0-render"
  }
  
  device_passthrough {
    deny_write = false
    gid        = 44
    mode       = "0660"
    path       = "/dev/dri/by-path/pci-0000:09:00.0-card"
  }

  lifecycle {
    ignore_changes = [
      started,
    ]
  }
}