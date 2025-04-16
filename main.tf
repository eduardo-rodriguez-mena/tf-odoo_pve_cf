####Para Cloudflare
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

variable "cloudflare_account_id" {
  type        = string
  description = "El ID de tu cuenta de Cloudflare"
  default     = "de1f5fea24729ce398e522a0623a2872"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "El ID de tu zona de Cloudflare"
  default     = "8b56d3ca360d3ec92212a6c12ef704a0"
}

variable "cloudflare_api_token" {
  type        = string
  description = "El API token de tu Cuenta de Cloudflare"
  default     = "kF9Eb3tEhmoHBVsrn8HD3gQasB3KXBmO6GErV_mo"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create a DNS record
resource "cloudflare_dns_record" "test111" {
    zone_id = var.cloudflare_zone_id
    name    = "test111"
    type    = "A"
    content = "192.0.2.1" # Replace with the desired IP address
    proxied = true
    ttl     = 1           # Set TTL to 1 for automatic TTL
}

####Para Proxmox

variable "pve_endpoint" {
  type        = string
  description = "El endpoint de tu entorno virtual"
  default     = "https://pve.yyogestiono.com:8006/api2/json/"
}

variable "pve_api_token" {
  type        = string
  description = "value of the API token"   
  default     = "terraform@pve!provider=ef8d178a-564a-4167-89e8-6c94103d7461"
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


data "proxmox_virtual_environment_node" "nodos" {
    for_each = toset(["vdc1-1", "vdc1-2", "vdc2-1", "vdc2-2"])
    node_name = each.value
}

output "nodos" {
  value = data.proxmox_virtual_environment_node.nodos
}

resource "proxmox_virtual_environment_container" "ubuntu_container" {
  description = "Managed by Terraform"

  node_name = "vdc2-2"
  vm_id     = 180

  initialization {
    hostname = "terraform-ubuntu"

    ip_config {
      ipv4 {
        address = "10.0.0.180/24"
        gateway = "10.0.0.11"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.ubuntu_container_key.public_key_openssh)
      ]
      password = random_password.ubuntu_container_password.result
    }
  }

  network_interface {
    name = "veth0"
    bridge = "Privada"

  }

  disk {
    datastore_id = "local-zfs"
    size         = 14
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.latest_ubuntu_22_jammy_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type             = "ubuntu"
  }

  mount_point {
    # volume mount, a new volume will be created by PVE
    volume = "local-zfs"
    size   = "10G"
    path   = "/mnt/volume"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "proxmox_virtual_environment_download_file" "latest_ubuntu_22_jammy_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "vdc2-2"
  url          = "http://download.proxmox.com/images/system/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
}

resource "random_password" "ubuntu_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "ubuntu_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "ubuntu_container_password" {
  value     = random_password.ubuntu_container_password.result
  sensitive = true
}

output "ubuntu_container_private_key" {
  value     = tls_private_key.ubuntu_container_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.ubuntu_container_key.public_key_openssh
}