locals {
  node_name = "proxmox"

  template_name          = "debian-13-genericcloud-template"
  template_vm_id          = 9001
  template_datastore_id   = "local-zfs"
  template_disk_size_gb   = 8
  template_ssh_username   = "db"
  root_password           = data.bitwarden-secrets_secret.vm_root_password.value
  ssh_public_key          = data.bitwarden-secrets_secret.ssh_pub_key2.value
  bridge                  = "vmbr0"

  # "latest" tracks the current Trixie point release (13.6.0 currently).
  debian_cloud_image_url = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

resource "proxmox_download_file" "debian_13_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = local.node_name

  url       = local.debian_cloud_image_url
  file_name = "debian-13-genericcloud-amd64.qcow2"

  overwrite = false
}

# Generic cloud-init vendor-data snippet: installs/enables qemu-guest-agent.
# Each VM supplies its own hostname via a separate meta-data snippet.
resource "proxmox_virtual_environment_file" "generic_cloud_init_vendordata" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.node_name

  source_raw {
    file_name = "generic-vendordata.yaml"
    data      = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - qemu-guest-agent
    runcmd:
      - systemctl enable --now qemu-guest-agent
    EOF
  }
}

resource "proxmox_virtual_environment_vm" "debian13_template" {
  name        = local.template_name
  description = "Debian 13.6 (Trixie) headless cloud-init template. Managed by Terraform."
  tags        = ["terraform", "template"]

  node_name = local.node_name
  vm_id     = local.template_vm_id

  machine   = "q35"

  template = true
  started  = false

  agent {
    enabled = true
    timeout = "60s"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = local.template_datastore_id
    import_from  = proxmox_download_file.debian_13_cloud_image.id
    interface    = "scsi0"
    size         = local.template_disk_size_gb
    discard      = "on"
    iothread     = true
    file_format  = "raw"
  }

  scsi_hardware = "virtio-scsi-single"

  network_device {
    bridge = local.bridge
  }

  # Headless: no VGA, serial console only.
  vga {
    type = "serial0"
  }
  serial_device {}

  boot_order = ["scsi0"]

  initialization {
    datastore_id = local.template_datastore_id
    interface    = "ide2"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      password = local.root_password
      username = "root"
      keys     = [local.ssh_public_key]
    }
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [
      initialization,
    ]
  }
}
