#Proxmox Secuity resources
resource "random_password" "odoo_template_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "odoo_template_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}