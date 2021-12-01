# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate5870"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.azure_region

  tags = {
    Environment = "Test"
    Owner       = "mskawslearn1@gmail.com"
  }
}

# Create a virtual network
#resource "azurerm_virtual_network" "vnet" {
#  name                = "main_vnet"
#  address_space       = ["10.0.0.0/16"]
#  location            = var.azure_region
#  resource_group_name = azurerm_resource_group.rg.name
#
#  subnet {
#    name           = "subnet1"
#    address_prefix = "10.0.1.0/24"
#  }
#
#  subnet {
#    name           = "subnet2"
#    address_prefix = "10.0.2.0/24"
#  }
#
#}

# Public IP for VM
#resource "azurerm_public_ip" "vm1_public_ip" {
#  name                = "vm1_public_ip"
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  allocation_method   = "Dynamic"
#}

# Network interface for VM
#resource "azurerm_network_interface" "vm1_nic" {
#  name                = "vm1_nic"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#
#  ip_configuration {
#    name                          = "internal"
#    subnet_id                     = azurerm_virtual_network.vnet.subnet.*.id[0]
#    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.vm1_public_ip.id
#  }
#}

#resource "azurerm_linux_virtual_machine" "admhost" {
#  name                = "admhost"
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  size                = "Standard_B1s"
#  admin_username      = "azureuser"
#  network_interface_ids = [
#    azurerm_network_interface.vm1_nic.id,
#  ]
#
#  admin_ssh_key {
#    username   = "azureuser"
#    public_key = file("~/.ssh/azure_key.pub")
#  }
#
#  os_disk {
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS"
#  }
#
#  source_image_reference {
#    publisher = "Debian"
#    offer     = "debian-11"
#    sku       = "11-gen2"
#    version   = "latest"
#  }
#}

resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_container_registry" "acr" {
  name                = "mskepamdiplomaacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}
