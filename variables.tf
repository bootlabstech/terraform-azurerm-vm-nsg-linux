variable "region" {
  type = string
}
#variable "resource_prefix" {
#  type = string
#}

variable "resource_prefix" {
  description = "Add the list of servernames that need to be created"
  type        = list(any)
  #default     = ["assess15", "assess16", "assess17"]
}


variable "node_address_space" {
  default = ["10.0.0.0/16"]
}
#variable for network range
variable "node_address_prefix" {
  default = ["10.0.1.0/24"]
}


variable "tag_id_map" {
  type = map(string)

  default = {
    environment = "production"
    application = "assessment"
  }
}

variable "version_no" {
  type = string
}

variable "image_name" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "vm_hostname" {
  type = string
}

variable "db_version" {
  type = number
}

variable "mysql_iops" {
  type = number
}

variable "storage_gb" {
  type = number
}

variable "sku_name" {
  type = string
}

variable "os_disk_sku" {
  type = string
}

variable "auto_grow_enabled" {
  type = bool
}

variable "backup_retention_days" {
  type = number
}

variable "geo_redundant_backup_enabled" {
  type = bool
}

variable "infrastructure_encryption_enabled" {
  type = bool
}

variable "public_network_access_enabled" {
  type = bool
}

variable "ssl_enforcement_enabled" {
  type = bool
}

variable "dns_domain_name" {
  type = string
}

variable "dns_resource_grp" {
  type = string
}

# variable "ip_allow" {
#   type = list(any)
# }

variable "source_server_name" {
  type = string
}
