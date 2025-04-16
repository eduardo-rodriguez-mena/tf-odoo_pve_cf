resource "proxmox_virtual_environment_container" "odoo_template" {
  description = <<EOT
# Detalles Servicio

Hostname: ${var.pve_hostname}
 
**IP:** 10.0.0.${var.pve_vmid}

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

  node_name = var.pve_nodename
  vm_id     = var.pve_vmid

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
    hostname = var.pve_hostname

    ip_config {
      ipv4 {
        address = "${var.pve_networkprefix}.${var.pve_vmid}/24"
        gateway = var.pve_gateway
      }
    }

    dns {
        domain = var.pve_domainname
        servers = var.pve_dnsservers
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
    host     = "${var.pve_networkprefix}.${var.pve_vmid}"
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
  node_name    = var.pve_nodename
  url          = "http://download.proxmox.com/images/system/${var.pve_template}"
}