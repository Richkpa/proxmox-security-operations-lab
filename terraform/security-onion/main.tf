terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.0.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  insecure = true # Set to true for self-signed homelab certificates
  username = var.proxmox_username
  password = var.proxmox_password
  
  ssh {
    agent    = true
    username = "root"
  }
}

resource "proxmoxvm" "security_onion" {
  name      = "var.proxmox_node_name"
  node_name = "agentnia"
  vm_id     = var.vm_id

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 16384
  }

  scsi_hardware = "virtio-scsi-single"

  # Using Security Onion
  cdrom {
    file_id   = "var.so_iso_path"
    interface = "ide0"
  }

  # OS Disk (200GB)
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 200
    iothread     = true
  }

  # Data Disk (100GB for /nsm)
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    size         = 100
    iothread     = true
  }

  # Boot from CD-ROM first (for installation), then hard disk
  boot_order = ["ide0", "scsi0"]

  network_device { 
    bridge = "var.mgmt_bridge" 
  }
  network_device { 
    bridge = "var.monitor_bridge" 
  }
}