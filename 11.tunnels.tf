# Create a DNS record
# resource "cloudflare_dns_record" "test111" {
#     zone_id = var.cloudflare_zone_id
#     name    = "test111"
#     type    = "A"
#     content = "192.0.2.1" # Replace with the desired IP address
#     proxied = true
#     ttl     = 1           # Set TTL to 1 for automatic TTL
# }

# 
# # data "cloudflare_zero_trust_tunnel_cloudflared_routes" "tunnel_routes" {
#     account_id = var.cloudflare_account_id
#     #tunnel_id  = var.cloudflare_tunnel_id
# }

data "cloudflare_zero_trust_tunnel_cloudflared" "tunnel_routes" {
    account_id = var.cloudflare_account_id
    name       = "EU_vDC1_Tun1"
}
