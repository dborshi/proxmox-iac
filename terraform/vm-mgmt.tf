resource "proxmox_virtual_environment_vm" "mgmt" {
  name        = "mgmt"
  description = "Omni and infrastructure management VM. Debian 13. Managed by OpenTofu."
    tags        = ["opentofu"]

  startup {
    down_delay = 1
    order      = 6
    up_delay   = 10
  }

  node_name = "proxmox"
  vm_id     = 112
  machine   = "q35"

  scsi_hardware = "virtio-scsi-single"

  clone {
    vm_id = local.template_vm_id
    full  = true
  }

  agent {
    enabled = true
    timeout = "60s"
  }

  # Force a hard stop instead of a graceful ACPI/agent-based shutdown on destroy.
  # Prevents terraform destroy from hanging if qemu-guest-agent isn't running yet.
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 32
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = local.bridge
  }

  vga {
    type = "serial0"
  }

  serial_device {}

  boot_order = ["scsi0"]

  initialization {
    datastore_id = "local-zfs"
    interface    = "ide2"

    vendor_data_file_id = proxmox_virtual_environment_file.generic_cloud_init_vendordata.id

    ip_config {
      ipv4 {
        address = "10.0.0.12/24"
        gateway = "10.0.0.1"
      }
    }

    dns {
      servers = ["10.0.0.22", "10.0.0.5"]
    }

    user_account {
      username = "db"
      keys     = [local.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  started = true

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      initialization    ]
  }
}
