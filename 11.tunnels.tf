# Create a DNS record
resource "cloudflare_dns_record" "test111" {
    zone_id = var.cloudflare_zone_id
    name    = "test111"
    type    = "A"
    content = "192.0.2.1" # Replace with the desired IP address
    proxied = true
    ttl     = 1           # Set TTL to 1 for automatic TTL
}