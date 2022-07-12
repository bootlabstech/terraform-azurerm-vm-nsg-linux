variable resource_group_name{
    type = string
    description = "name of the resource group"
}

variable location{
    type = string
    description = "location of the resource group"
}

variable vms_configuration {
  description = "the main input variable which has all the configuration regarding the vm to be created"
  type        = list(object({
    name               = string,
    public_ip_enabled  = bool,
    vnet_name          = string,
    subnet_id          = list(string),
    vm_size            = string,
    storage_os_disk    = object({
      create_option             = string,
      caching                   = optional(string),
      disk_size_gb              = optional(number),
      image_uri                 = optional(string), 
      os_type                   = optional(string),
      write_accelerator_enabled = optional(string),
      managed_disk_id           = optional(string),
      managed_disk_type         = optional(string),
      vhd_uri                   = optional(string),
    }),
    image_publisher    = string,
    image_offer        = string,
    image_sku          = string,
    image_version      = string,
    os_username        = string,
    os_password        = string,
    os_type            = string,
  }))
}