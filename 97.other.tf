####Para Proxmox
resource "proxmox_virtual_environment_download_file" "debian-12-standard_lxc_img" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = "vdc2-2"
  url          = "http://download.proxmox.com/images/system/debian-12-standard_12.7-1_amd64.tar.zst"
}