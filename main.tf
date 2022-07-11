terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.93.0"
    }
  }
    backend "azurerm" {
    resource_group_name  = "IAAC"
    storage_account_name = "infracodeterraform"
    container_name       = "tfstate"
    key                  = "doapp/doapp_31_35.tfstate"
    #access_key = "__storagekey__"
  }
}

# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  #subscription_id = "9fcc9c96–8044–XXXX-XXXX–XXXXXXXXXXXX"
  #client_id = "97545937–XXXX–XXXX-XXXX-XXXXXXXXXXXX"
  #client_secret = ".3GGR_XXXXX~XXXX-XXXXXXXXXXXXXXXX"
  #tenant_id = "73d20f0d-XXXX–XXXX–XXXX-XXXXXXXXXXXX"
  #  version = "2.81.0"
  features {}
}
# Create a resource group
resource "azurerm_resource_group" "bootlab_rg" {
  count    = length(var.resource_prefix)
  name     = var.resource_prefix[count.index]
  location = var.region
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "bootlab_vnet" {
  count               = length(var.resource_prefix)
  name                = "${var.resource_prefix[count.index]}-vnet"
  resource_group_name = azurerm_resource_group.bootlab_rg[count.index].name
  location            = var.region
  address_space       = var.node_address_space
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "bootlab_subnet" {
  count                = length(var.resource_prefix)
  name                 = "${var.resource_prefix[count.index]}-subnet"
  resource_group_name  = azurerm_resource_group.bootlab_rg[count.index].name
  virtual_network_name = azurerm_virtual_network.bootlab_vnet[count.index].name
  address_prefixes     = var.node_address_prefix
}

# Create Linux Public IP
resource "azurerm_public_ip" "bootlab_public_ip" {
  count               = length(var.resource_prefix)
  name                = "${var.resource_prefix[count.index]}-PublicIP"
  location            = azurerm_resource_group.bootlab_rg[count.index].location
  resource_group_name = azurerm_resource_group.bootlab_rg[count.index].name
  allocation_method   = "Static"
  tags = {
    environment = var.tag_id_map["environment"]
    application = var.tag_id_map["application"]
  }
}

# Create Network Interface
resource "azurerm_network_interface" "bootlab_nic" {
  count               = length(var.resource_prefix)
  name                = "${var.resource_prefix[count.index]}-NIC"
  location            = azurerm_resource_group.bootlab_rg[count.index].location
  resource_group_name = azurerm_resource_group.bootlab_rg[count.index].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bootlab_subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.bootlab_public_ip.*.id, count.index)
  }
}

# Creating resource NSG
resource "azurerm_network_security_group" "bootlab_nsg" {
  count               = length(var.resource_prefix)
  name                = "${var.resource_prefix[count.index]}-NSG"
  location            = azurerm_resource_group.bootlab_rg[count.index].location
  resource_group_name = azurerm_resource_group.bootlab_rg[count.index].name
  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  # security_rule {
  #   name                       = "Inbound"
  #   priority                   = 100
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "Tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "*"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
  tags = {
    environment = var.tag_id_map["environment"]
    application = var.tag_id_map["application"]
  }
}

#Creating the Network security rules for VMs
resource "azurerm_network_security_rule" "bootlab_nsg_rule1" {
  count                       = length(var.resource_prefix)
  name                        = "SSH"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.bootlab_rg[count.index].name
  network_security_group_name = azurerm_network_security_group.bootlab_nsg[count.index].name
}

resource "azurerm_network_security_rule" "bootlab_nsg_rule2" {
  count                       = length(var.resource_prefix)
  name                        = "HTTP"
  priority                    = 301
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.bootlab_rg[count.index].name
  network_security_group_name = azurerm_network_security_group.bootlab_nsg[count.index].name
}

resource "azurerm_network_security_rule" "bootlab_nsg_rule3" {
  count                       = length(var.resource_prefix)
  name                        = "HTTPS"
  priority                    = 302
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.bootlab_rg[count.index].name
  network_security_group_name = azurerm_network_security_group.bootlab_nsg[count.index].name
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "bootlab_subnet_nsg_association" {
  count                     = length(var.resource_prefix)
  subnet_id                 = azurerm_subnet.bootlab_subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.bootlab_nsg[count.index].id
}

# Share Image Version
data "azurerm_shared_image_version" "bootlab_image_version" {
  name                = var.version_no
  image_name          = var.image_name
  gallery_name        = var.gallery_name
  resource_group_name = var.resource_group_name
}

# Virtual Machine Creation — Linux
resource "azurerm_virtual_machine" "bootlab_linux_vm" {
  count                         = length(var.resource_prefix)
  name                          = var.resource_prefix[count.index]
  location                      = azurerm_resource_group.bootlab_rg[count.index].location
  resource_group_name           = azurerm_resource_group.bootlab_rg[count.index].name
  network_interface_ids         = [element(azurerm_network_interface.bootlab_nic.*.id, count.index)]
  vm_size                       = var.vm_size
  delete_os_disk_on_termination = true
}
  storage_image_reference {
    id = data.azurerm_shared_image_version.bootlab_image_version.id
  }
  #source_image_id=data.azurerm_shared_image_version.example.id
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "16.04-LTS"
  #   version   = "latest"
  # }
  storage_os_disk {
    name              = "vmosdisk-${var.resource_prefix[count.index]}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.os_disk_sku
  }
  #os_profile {
  # computer_name  = var.resource_prefix[count.index]
  # admin_username = "udap-prod"
  # admin_password = "Cintana@123"
  #}
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.tag_id_map["environment"]
    application = var.tag_id_map["application"]
  }


# #DNS A Record Creation
# resource "azurerm_dns_a_record" "bootlab_dns_entry" {
#   count               = length(var.resource_prefix)
#   name                = var.resource_prefix[count.index]
#   zone_name           = var.dns_domain_name
#   resource_group_name = var.dns_resource_grp
#   ttl                 = 300
#   records             = [azurerm_public_ip.bootlab_public_ip[count.index].ip_address]
# }

