terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example_rg" {
  name     = "${var.resource_prefix}-rg"
  location = var.node_location
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
}

resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
}

resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefix       = var.node_address_prefix
}

/* resource "azurerm_public_ip" "example_public_ip" {
  count = var.node_count
  name = "${var.resource_prefix}-${format("%02d”,count.index)}-PublicIP"
  #name = “${var.resource_prefix}-PublicIP”
  location = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method = var.Environment == "Test" ? "Static" : "Dynamic"
  tags = {
  environment = "Test"
} */
resource "azurerm_public_ip" "example_public_ip" {
  count = var.node_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  #name = “${var.resource_prefix}-PublicIP”
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = var.Environment == "Test" ? "Static" : "Dynamic"
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
}
resource "azurerm_network_interface" "example_nic" {
  count = var.node_count
  #name = “${var.resource_prefix}-NIC”
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
  #
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
    #public_ip_address_id = azurerm_public_ip.example_public_ip.id
  }
}

resource "azurerm_network_security_group" "example_nsg" {
  name                = "${var.resource_prefix}-NSG"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  /* security_rule {
  name = "Inbound"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  } */
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
}
# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}
# Virtual Machine Creation — Linux
resource "azurerm_virtual_machine" "example_linux_vm" {
  count = var.node_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}"
 // name  = "${format("%02d", count.index)}"
  #name = “${var.resource_prefix}-VM”
  location                      = azurerm_resource_group.example_rg.location
  resource_group_name           = azurerm_resource_group.example_rg.name
  network_interface_ids         = [element(azurerm_network_interface.example_nic.*.id, count.index)]
  vm_size                       = "Standard_A1_v2"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "linuxvm-${format("%02d", count.index)}"
    admin_username = "kirti"
    admin_password = "Password@1234"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Test"
    Owner       = "Kirti Bansal"
  }
}