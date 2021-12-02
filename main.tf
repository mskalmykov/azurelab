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

resource "azurerm_mariadb_server" "dbsrv" {
  name                = "mskepamdiplomadb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login           = "nhltop"
  administrator_login_password  = var.DB_PASSWORD
  version                       = "10.3"
  ssl_enforcement_enabled       = false
}

resource "azurerm_mariadb_database" "dbprod" {
  name                = "nhltop"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbsrv.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mariadb_database" "dbtest" {
  name                = "test"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbsrv.name
  charset             = "utf8"
  collation           = "utf8_general_ci"
}

resource "azurerm_mariadb_firewall_rule" "db_firewall_rule" {
  name                = "permit-azure"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mariadb_server.dbsrv.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
