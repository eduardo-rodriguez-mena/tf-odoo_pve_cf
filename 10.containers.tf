resource "proxmox_virtual_environment_container" "odoo_template" {
  description = <<EOT
# Detalles Servicio

Hostname: ${var.pve_container.hostname}
 
**IP:** 10.0.0.${var.pve_container.vmid}

**FQDN:** ${var.pve_container.hostname}.${var.pve_container.domainname}

**Deployed Services: (Docker)** 

      [ ] Odoo Web

      [ ] Odoo DB

      [X] Odoo AiO (Web+DB)

**Ports:** 80,443,5432 TCP

**Admin User:** root

**Admin Password:** ${random_password.odoo_template_password.result}

**Deployed by:** 

**Deployed Using:** Terraform

**Version:** 1.0

**Observations:**
EOT

  node_name = var.pve_container.nodename
  vm_id     = var.pve_container.vmid

  cpu {
    cores = var.pve_container.cores
    units = 100
  } 

  memory {
    dedicated = var.pve_container.ram
    swap = var.pve_container.swap
  }

  unprivileged = true

  features {
    nesting = true
  }

  tags = ["terraform", "debian12", "docker", "odoo"]

  initialization {
    hostname = "${var.pve_container.hostname}-${var.pve_container.deploymenttype}"

    ip_config {
      ipv4 {
        address = "${var.pve_container.networkprefix}.${var.pve_container.vmid}/24"
        gateway = var.pve_container.gateway
      }
    }

    dns {
        domain = var.pve_container.domainname
        servers = var.pve_container.dnsservers
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
    size         = var.pve_container.disksize
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
    host     = "${var.pve_container.networkprefix}.${var.pve_container.vmid}"
  }

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt dist-upgrade -y",
      #Install & Config Git
      "apt install -y git",
      "git config --global user.name Admin_Terraform", 
      "git config --global user.email ${var.resposible_email}",
      #Sincronizar y personalizar Proyecto de composer
      "cd /",
      "git init",
      "git clone https://github.com/eduardo-rodriguez-mena/odoo-template.git",
      "mv odoo-template app",
      #Seleccionando la carpeta adecuada para depsliegue
      "cd /app/odoo-${lower(var.pve_container.deploymenttype)}/",
      #Configurando el entorno
      "sed -i s/^HOST_NAME=.*/HOST_NAME=${var.pve_container.hostname}.${var.pve_container.domainname}/ .env",
      "sed -i s/^LE_EMAIL=.*/LE_EMAIL=${var.resposible_email}/ .env",
      "sed -i s/^ODOO_DATABASE=.*/ODOO_DATABASE=${var.app.db_name}/ .env",
      "sed -i s/^DB_HOST=.*/DB_HOST=${var.app.db_host}/ .env",
      "sed -i s/^ODOO_TAG=.*/ODOO_TAG=${var.app.odoo_tag}/ .env",
      "sed -i s/^POSTGRES_TAG=.*/POSTGRES_TAG=${var.app.postgres_tag}/ .env",
      "sed -i s/^ODOO_DB_PASS=.*/ODOO_DB_PASS=${var.app.odoo_db_password}/ .env",
      "sed -i s/^OLD_PROJETC_DIR=.*/OLD_PROJETC_DIR=${var.app.odoo_origin_pass}/ .env",
      "sed -i s/^ODOO_ORIGIN_HOST=.*/ODOO_ORIGIN_HOST=${var.app.odoo_origin_ip}/ .env",
      "sed -i s/^RSYNC_PASSWORD=.*/RSYNC_PASSWORD=${var.app.odoo_origin_pass}/ .env",
      "sed -i s/^ODOO_ORIGIN_SITE=.*/ODOO_ORIGIN_SITE=${var.app.odoo_origin_hostname}/ .env",
      "sed -i s/^ADMIN_PASSWORD=.*/ADMIN_PASSWORD=${var.app.odoo_admin_password}/ .env",
      #Install Docker
      "apt install -y ca-certificates curl",
      "curl -fsSL https://get.docker.com -o get-docker.sh",
      "bash get-docker.sh",
      "apt install -y docker-compose-plugin",
      #Fijar carpeta de trabajo
      "echo cd /app/odoo-${lower(var.pve_container.deploymenttype)} >> /root/.bashrc",
      
      ]
  }
}

resource "proxmox_virtual_environment_download_file" "debian-12-standard_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.pve_container.nodename
  url          = "http://download.proxmox.com/images/system/${var.pve_container.template}"
}