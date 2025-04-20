terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.52.0"
    }
    proxmox = {
        source = "bpg/proxmox"
        version = "0.75.0"
      }
    }
  }

