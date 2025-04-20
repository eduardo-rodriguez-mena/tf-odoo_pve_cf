provider "cloudflare" {
  api_token = var.cloudflare_api_token
  #email     = var.resposible_email
}

provider "proxmox" {
  endpoint  = var.pve_endpoint
  api_token = var.pve_api_token
  #insecure  = true
   ssh {
    agent    = true
    username = "terraform"
  }
}