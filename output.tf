output "resource_group_name" {
  description = "Azure Resource Group Name"
  value       = var.resource_group_name
}

output "cloud" {
  description = "Cloud Provider"
  value       = "Azure"
}

output "vm_resource_id" {
  description = "Azure VM Resource ID"
  value       = azurerm_linux_virtual_machine.vm.id
}