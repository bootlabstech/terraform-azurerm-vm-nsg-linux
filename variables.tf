# virtual_machine
variable "name" {
  type        = string
  description = "Specifies the name of the Virtual Machine. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "name of the resource group"
}

variable "location" {
  type        = string
  description = "location of the resource group"
}



variable "vm_size" {
  type        = string
  description = "Specifies the size of the Virtual Machine. See also Azure VM Naming Conventions."
}

# storage_image_reference
variable "publisher" {
  type        = string
  description = " Specifies the publisher of the image used to create the virtual machine. Examples: Canonical, MicrosoftWindowsServer"
}

variable "offer" {
  type        = string
  description = "Specifies the offer of the image used to create the virtual machine. Examples: UbuntuServer, WindowsServer"
}

variable "sku" {
  type        = string
  description = "Specifies the SKU of the image used to create the virtual machine. Examples: 18.04-LTS, 2019-Datacenter"
}

variable "storage_image_version" {
  type        = string
  description = "Specifies the version of the image used to create the virtual machine. Changing this forces a new resource to be created."
  # default     = "latest"
}


# storage_os_disk
variable "caching" {
  type        = string
  description = "Specifies the caching requirements for the Data Disk. Possible values include None, ReadOnly and ReadWrite."
  default     = "ReadWrite"
}

variable "create_option" {
  type        = string
  description = "Specifies how the data disk should be created. Possible values are Attach, FromImage and Empty."
  default     = "FromImage"
}

variable "managed_disk_type" {
  type        = string
  description = "Specifies the type of managed disk to create. Possible values are either Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS."
}

variable "os_type" {
  type        = string
  description = "Specifies the Operating System on the OS Disk. Possible values are Linux and Windows."
}

# os_profile
variable "admin_username" {
  type        = string
  description = "Specifies the name of the local administrator account."
}

variable "admin_password" {
  type        = string
  description = "The password associated with the local administrator account."
}

variable "custom_data" {
  type        = string
  description = "Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script."
}
# network_interface
variable "network_interface_name" {
  type        = string
  description = "The name of the Network Interface. Changing this forces a new resource to be created."
}

variable "ip_name" {
  type        = string
  description = "A name used for this IP Configuration."
  default     = "internal"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the Subnet where this Network Interface should be located in."
}

variable "private_ip_address_allocation" {
  type        = string
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static"
}

variable "disable_password_authentication" {
  type        = bool
  description = "Specifies whether password authentication should be disabled. If set to false, an admin_password must be specified."
  default     = false
}

variable "timezone" {
  type        = string
  description = "(optional) describe your variable"
  default     = "India Standard Time"
}

variable "delete_os_disk_on_termination" {
  type        = bool
  description = " Should the OS Disk (either the Managed Disk / VHD Blob) be deleted when the Virtual Machine is destroyed? Defaults to false."
  default     = true
}

variable "delete_data_disks_on_termination" {
  type        = bool
  description = "Should the Data Disks (either the Managed Disks / VHD Blobs) be deleted when the Virtual Machine is destroyed? Defaults to false."
  default     = true
}