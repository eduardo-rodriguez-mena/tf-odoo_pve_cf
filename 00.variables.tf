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
