#Cloudfalre Variabñes

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


#Proxmox Variables

variable "pve_vmid" {
  type        = number
  description = "El ID del contenedor"
  default     = 180
}

variable "pve_template" {
  type        = string
  description = "El ID de la plantilla"
  default     = "debian-12-standard_12.0-1_amd64.tar.xz"
}

variable "pve_nodename" {
  type        = string
  description = "El nombre del nodo para desplegar el contenedor"
  default     = "vdc2-2"
}

variable "pve_networkprefix" {
  type        = string
  description = "El prefijo de la red Privada"
  default     = "10.0.0"
}

variable "pve_gateway" {
  type        = string
  description = "El gateway de la red Privada para contenedor"
  default     = "10.0.0.10"
}

variable "pve_dnsservers" {
  type       = list(string)
  description = "Los servidores DNS de la red Privada para contenedor"
  default = [ "10.0.0.10", "10.0.0.11" ]
}

variable "pve_endpoint" {
  type        = string
  description = "El endpoint de tu entorno virtual"
  default     = "https://pve.yyogestiono.com:8006/api2/json/"
}

variable "pve_hostname" {
  type        = string
  description = "El nombre del Contendor"
  default     = "test1"
}

variable "pve_domainname" {
  type        = string
  description = "El dominio del contenedor"
  default     = "yyogestiono.com"
}

variable "pve_api_token" {
  type        = string
  description = "value of the API token"   
  default     = "terraform@pve!provider=ef8d178a-564a-4167-89e8-6c94103d7461"
}

#Valores determinados
locals {
  pve_gateway    = substr(var.pve_nodename, 0, 5) == "vdc2-" ? "10.0.0.10" : "10.0.0.11"
  pve_dnsservers = substr(var.pve_nodename, 0, 5) == "vdc2-" ? [ "10.0.0.10", "10.0.0.11" ] : [ "10.0.0.11", "10.0.0.10" ]
}
