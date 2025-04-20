#Cloudfalre Variabñes

variable "cloudflare_account_id" {
  type        = string
  description = "El ID de tu cuenta de Cloudflare"
  default     = "de1f5fea24729ce398e522a0623a2872"
}

variable "cloudflare_tunnel_id" {
  type        = string
  description = "El ID de tu túnel de Cloudflare"
  default     = "f1fbce14-6292-4eab-98fa-356f8abb511e"
}

variable "cloudflare_tunnel_name" {
  type        = string
  description = "El nombre de tu túnel de Cloudflare"
  default     = "tunnel-terraform"
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

variable "pve_container" {
  type        = object({
    ram    = number
    cores  = number
    swap   = number
    disksize = number
    vmid   = number
    hostname = string
    domainname = string
    nodename    = string
    template = string
    deploymenttype = string
    environment = string
    networkprefix = string
    gateway = string
    dnsservers = list(string)
 
  })
  description = "Define los parametros del contenedor a desplegar"
  default     = {
    ram     = 2048
    cores   = 2
    swap    = 2048
    disksize = 16
    vmid    = 180
    hostname = "test1"
    domainname = "yyogestiono.com"
    nodename = "vdc1-2"
    template = "debian-12-standard_12.7-1_amd64.tar.zst"
    deploymenttype = "AiO"
    environment = "dev"        #Pude ser "test", dev o "prod"
    networkprefix = "10.0.0"
    gateway = "10.0.0.10"
    dnsservers = [ "10.0.0.10", "10.0.0.11" ]
   }
}

variable "app" {
  type        = object({
    db_host = string 
    odoo_tag = string
    postgres_tag = string
    odoo_db_password = string
    db_name = string
    odoo_admin_password = string
    odoo_origin_dir = string
    odoo_origin_ip = string
    odoo_origin_pass = string
    odoo_origin_hostname = string
    deploymenttype = string
})
  description = "Objeto para migación de Odoo"
  default = {
    db_host = "db"
    odoo_tag = "17.0"
    postgres_tag = "15.0"
    odoo_db_password = "jrC9**0+3iU5AA="
    db_name = "db_dev"
    odoo_admin_password = "1Qazxsw2/*-+"
    odoo_origin_dir = "/app/odoo-almacaribe/docker"
    odoo_origin_ip = "89.117.74.155"
    odoo_origin_pass = "lAnXPVyPyjRCrcu294QZ2P"
    odoo_origin_hostname = "yyogestiono.com"
    deploymenttype = "new" #puede ser "migration" o "new"
  }
}


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

variable "resposible_email" {
  type        = string
  description = "Email del responsable del despliegue"
  default     = "it@yyogestiono.com"
}

#Valores Calculados
locals {
  pve_container = {
    gateway     = substr(var.pve_container.nodename, 0, 5) == "vdc2-" ? "10.0.0.10" : "10.0.0.11"
    dnsservers  = substr(var.pve_container.nodename, 0, 5) == "vdc2-" ? [ "10.0.0.10", "10.0.0.11" ] : [ "10.0.0.11", "10.0.0.10" ]
    cores      = var.pve_container.environment == "prod" ? 4 : 2
    ram        = var.pve_container.environment == "prod" ? 4096 : 2048
    swap       = var.pve_container.environment == "prod" ? 4096 : 2048
    disk_size  = var.pve_container.environment == "prod" ? 32 : 16
}

  app = {
    db_name = "${var.pve_container.hostname}_${var.pve_container.environment}"
  }
}

