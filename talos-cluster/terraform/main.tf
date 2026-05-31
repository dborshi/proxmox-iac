locals {
  nodes = {
    talos-cp-1 = { id = 1001, ip = "10.0.0.41", cores = 3, mem = 8192 }
    talos-wk-1 = { id = 1002, ip = "10.0.0.42", cores = 4, mem = 8192 }
    talos-wk-2 = { id = 1003, ip = "10.0.0.43", cores = 4, mem = 8192 }
  }
}

resource "proxmox_virtual_environment_vm" "talos_nodes" {
  for_each  = local.nodes
  name      = each.key
  node_name = "proxmox"
  vm_id     = each.value.id

  clone {
    vm_id = 9000
    full  = true
  }

  cpu     {
    cores = each.value.cores
    type  = "host"
    }
  memory  { dedicated = each.value.mem }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 50
  }

  network_device { bridge = "vmbr0" }
}