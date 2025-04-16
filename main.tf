terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    proxmox = {
      source = "bpg/proxmox"
      version = "0.75.0"
    }
  }
}

