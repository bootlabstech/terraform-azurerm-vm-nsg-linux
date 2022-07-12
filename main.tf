terraform {
  experiments = [module_variable_optional_attrs]
}

module "vm" {
    source = "./modules/vm"
    resource_group_name   = var.resource_group_name
    location              = var.location
    for_each = { for vm in var.vms_configuration : vm.name => vm }
    vms_configuration = [
    {
        name = each.value.name
        public_ip_enabled = each.value.public_ip_enabled
        vnet_name         = each.value.vnet_name
        subnet_id         = each.value.subnet_id
        vm_size           = each.value.vm_size
        storage_os_disk = {
            caching           = "ReadWrite"
            create_option     = "FromImage"
            managed_disk_type = "Premium_LRS"
            # disk_size_gb      = var.disk_size
      }
      image_publisher = each.value.image_publisher
      image_offer     = each.value.image_offer
      image_sku       = each.value.image_sku
      image_version   = each.value.image_version
      os_username     = each.value.os_username
      os_password     = each.value.os_password
      os_type         = "Linux"
    }
    ]
}