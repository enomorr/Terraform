provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "enomor" {
  name     = "enomorTerra"
  location = "North Europe"
}

resource "azurerm_virtual_network" "Terra" {
  name                = "terra-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.enomor.location
  resource_group_name = azurerm_resource_group.enomor.name
}

resource "azurerm_subnet" "enomor" {
  name                 = "enomor-terra"
  resource_group_name  = azurerm_resource_group.enomor.name
  virtual_network_name = azurerm_virtual_network.Terra.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "enor-tera" {
  name                = "terra-nic"
  location            = azurerm_resource_group.enomor.location
  resource_group_name = azurerm_resource_group.enomor.name
  
  ip_configuration {
    name                          = "enor-terra"
    subnet_id                     = azurerm_subnet.enomor.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id  = azurerm_public_ip.enomor.id
    
  }
  
}

resource "azurerm_public_ip" "enomor" {
  name                = "enomor"
  resource_group_name = azurerm_resource_group.enomor.name
  location            = azurerm_resource_group.enomor.location
  allocation_method   = "Static"

  tags = {
    environment = "eno-terra"
  }
}

resource "azurerm_windows_virtual_machine" "enomorVM" {
  name                = "EnomorTerraVM"
  resource_group_name = azurerm_resource_group.enomor.name
  location            = azurerm_resource_group.enomor.location
  size                = "Standard_F2"
  admin_username      = "morris"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.enor-tera.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}