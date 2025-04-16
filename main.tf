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

#data "proxmox_virtual_environment_node" "nodos" {
#    for_each = toset(["vdc1-1", "vdc1-2", "vdc2-1", "vdc2-2"])
#    node_name = each.value
#}

# output "nodos" {
#   value = data.proxmox_virtual_environment_node.nodos
# }

resource "proxmox_virtual_environment_container" "odoo_template" {
  description = <<EOT
# Detalles Servicio

Hostname: odoo-template
 
**IP:** 10.0.0.180

**Deployed Services: (Docker)** 

      [ ] Odoo Web

      [ ] Odoo DB

      [X] Odoo AiO (Web+DB)

**Ports:** 80,443,5432 TCP

**Admin User:** root

**Admin Password:** ${random_password.odoo_template_password.result}

**Deployed by:**

**Deployed from:** Terraform

**Version:** 1.0

**Observations:**
EOT

  node_name = "vdc2-2"
  vm_id     = 180

  cpu {
    cores = 2
    units = 100
  } 

  memory {
    dedicated = 2048
    swap = 2048
  }

  unprivileged = true

  features {
    nesting = true
  }

  tags = ["terraform", "debian12", "docker", "odoo"]

  initialization {
    hostname = "odoo-template"

    ip_config {
      ipv4 {
        address = "10.0.0.180/24"
        gateway = "10.0.0.10"
      }
    }

    dns {
        domain = "yyogestiono.com"
        servers = ["10.0.0.10", "10.0.0.11"] 
    }

    user_account {
      keys = [
        trimspace(tls_private_key.odoo_template_key.public_key_openssh)
      ]
      password = random_password.odoo_template_password.result
    }
  }

  network_interface {
    name = "eth0"
    bridge = "Private"
    rate_limit = 10
  }

  disk {
    datastore_id = "local-zfs"
    size         = 16
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.debian-12-standard_lxc_img.id
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type             = "debian"
  }

   startup {    
    order      = "100"
    up_delay   = "20"
    down_delay = "20"
  }

  connection {
    type     = "ssh"
    user     = "root"
    #password = random_password.odoo_template_password.result
    private_key = tls_private_key.odoo_template_key.private_key_pem
    host     = "10.0.0.180"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt dist-upgrade -y",
      #Install & Config Git
      "apt install -y git",
      "git config --global user.name Admin_Terraform", 
      "git config --global user.email it@yyogestiono.com",
      "cd /",
      "git init",
      "git clone https://github.com/eduardo-rodriguez-mena/odoo-template.git",
      "mv odoo-template app",
      #Install Docker
      "apt install -y ca-certificates curl",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "bash get-docker.sh",
      "apt install -y docker-compose-plugin",
      "echo 'cd /app/' >> /root/.bashrc",
    ]
  }


}

resource "proxmox_virtual_environment_download_file" "debian-12-standard_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "vdc2-2"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}

resource "random_password" "odoo_template_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "odoo_template_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "odoo_template_password" {
  value     = random_password.odoo_template_password.result
  sensitive = true
}

output "odoo_template_private_key" {
  value     = tls_private_key.odoo_template_key.private_key_pem
  sensitive = true
}

output "ubuntu_container_public_key" {
  value = tls_private_key.odoo_template_key.public_key_openssh
}

