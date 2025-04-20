#Cloudfare Outputs
output "example_tunnel_routes" {
    value = data.cloudflare_zero_trust_tunnel_cloudflared.tunnel_routes.id
}
#Proxmox Outputs

#data "proxmox_virtual_environment_node" "nodos" {
#    for_each = toset(["vdc1-1", "vdc1-2", "vdc2-1", "vdc2-2"])
#    node_name = each.value
#}

# output "nodos" {
#   value = data.proxmox_virtual_environment_node.nodos
# }

output "odoo_template_password" {
  value     = random_password.odoo_template_password.result
  sensitive = true
}

output "odoo_template_private_key" {
  value     = tls_private_key.odoo_template_key.private_key_pem
  sensitive = true
}

output "odoo_template_public_key" {
  value = tls_private_key.odoo_template_key.public_key_openssh
}

