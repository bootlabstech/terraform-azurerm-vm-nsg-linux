# Creates a Azure Linux Virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  network_interface_ids           = [azurerm_network_interface.nic.id]
  size                            = var.size
  admin_username                  = var.admin_username
  admin_password                  = random_password.password.result
  disable_password_authentication = var.disable_password_authentication
  source_image_id                 = var.source_image_id
  # source_image_reference {
  #   publisher = var.publisher
  #   offer     = var.offer
  #   sku       = var.sku
  #   version   = var.storage_image_version
  # }
  
  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = var.caching
    storage_account_type = var.storage_account_type
    disk_size_gb         = var.disk_size_gb
  }
  depends_on = [
    azurerm_network_interface.nic
  ]
  lifecycle {
    ignore_changes = [
      tags,
      boot_diagnostics
    ]
  }

  identity {type = var.identity}

}

# Creates Network Interface Card with private IP for Virtual Machine
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = var.ip_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
  }
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Creates Network Security Group NSG for Virtual Machine
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.name}-nsg"
  location            = azurerm_linux_virtual_machine.vm.location
  resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

}

# Creates Network Security Group Default Rules for Virtual Machine
resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                    = var.nsg_rules
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_address_prefix       = each.value.source_address_prefix
  source_port_range           = each.value.source_port_range
  destination_address_prefix  = each.value.destination_address_prefix
  destination_port_range      = each.value.destination_port_range
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_linux_virtual_machine.vm.resource_group_name
}


# Creates association (i.e) adds NSG to the NIC
resource "azurerm_network_interface_security_group_association" "security_group_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Getting existing recovery_services_vault to add vm as a backup item 
data "azurerm_recovery_services_vault" "services_vault" {
  name                = var.recovery_services_vault_name
  resource_group_name = var.services_vault_resource_group_name
}

# Getting existing Backup Policy for Virtual Machine
data "azurerm_backup_policy_vm" "policy" {
  name                = "VM-backup-policy"
  recovery_vault_name = data.azurerm_recovery_services_vault.services_vault.name
  resource_group_name = data.azurerm_recovery_services_vault.services_vault.resource_group_name
}

# Creates Backup protected Virtual Machine
resource "azurerm_backup_protected_vm" "backup_protected_vm" {
  resource_group_name = data.azurerm_recovery_services_vault.services_vault.resource_group_name
  recovery_vault_name = data.azurerm_recovery_services_vault.services_vault.name
  source_vm_id        = azurerm_linux_virtual_machine.vm.id
  backup_policy_id    = data.azurerm_backup_policy_vm.policy.id
  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]

}



# Extention for startup ELK script
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "${var.name}-defender"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "fileUris": ["https://sharedsaelk.blob.core.windows.net/s1-data/install_linux_defender.sh"],
      "commandToExecute": "sh install_linux_defender.sh"
    }
SETTINGS
}

# Getting existing Keyvault name to store credentials as secrets
data "azurerm_key_vault" "key_vault" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

# Creates a random string password for vm default user
resource "random_password" "password" {
  length      = 12
  lower       = true
  min_lower   = 6
  min_numeric = 2
  min_special = 2
  min_upper   = 2
  numeric     = true
  special     = true
  upper       = true

}
# Creates a secret to store DB credentials 
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "${var.name}-vmpwd"
  value        = random_password.password.result
  key_vault_id = data.azurerm_key_vault.key_vault.id

  depends_on = [ azurerm_linux_virtual_machine.vm ]
}