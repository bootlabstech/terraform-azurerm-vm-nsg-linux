terraform {
  experiments = [module_variable_optional_attrs]
}

resource "azurerm_subnet" "subnet" {
  for_each = { for vm in var.vms_configuration : vm.name => vm }
  name                 = "sailor-subnet-01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.subnet_id
}

resource "azurerm_network_interface" "vm_nic" { 
  for_each = { for vm in var.vms_configuration : vm.name => vm }
  name                = "${each.key}-${random_string.server_suffix[each.key].id}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfiguration1"
    subnet_id                     =  azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.public_ip_enabled ? azurerm_public_ip.vm_public_ip[each.key].id : null
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "random_string" "server_suffix" {
  for_each = { for vm in var.vms_configuration : vm.name => vm }
  length           = 8
  special          = false
  upper            = false 
  lower            = true
  number           = true
}

resource "azurerm_public_ip" "vm_public_ip" {
  for_each = { 
    for vm in var.vms_configuration : vm.name => vm
    if vm.public_ip_enabled
  }
  name                = "${each.key}-${random_string.server_suffix[each.key].id}-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  domain_name_label   = "${each.key}-${random_string.server_suffix[each.key].id}"

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_virtual_machine" "vm" {
  for_each = { for vm in var.vms_configuration : vm.name => vm }
  name                  = "${each.key}-${random_string.server_suffix[each.key].id}-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic[each.key].id]
  vm_size               = each.value.vm_size

  storage_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  storage_os_disk {
    name                      = "${each.key}-${random_string.server_suffix[each.key].id}-os-disk"
    caching                   = each.value.storage_os_disk.caching                  
    create_option             = each.value.storage_os_disk.create_option            
    disk_size_gb              = each.value.storage_os_disk.disk_size_gb             
    image_uri                 = each.value.storage_os_disk.image_uri                
    os_type                   = each.value.storage_os_disk.os_type                  
    write_accelerator_enabled = each.value.storage_os_disk.write_accelerator_enabled
    managed_disk_id           = each.value.storage_os_disk.managed_disk_id          
    managed_disk_type         = each.value.storage_os_disk.managed_disk_type        
    vhd_uri                   = each.value.storage_os_disk.vhd_uri                  
  }

  os_profile {
    computer_name  = "${each.key}-${random_string.server_suffix[each.key].id}"
    admin_username = each.value.os_username
    admin_password = each.value.os_password
  }

 dynamic os_profile_linux_config {
    for_each = each.value.os_type == "Linux" ? [1] : []
    content {
      disable_password_authentication = false
    }
  }

 dynamic os_profile_windows_config {
    for_each = each.value.os_type == "Windows" ? [1] : []
    content {
      provision_vm_agent = false
    }
  }
  
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}