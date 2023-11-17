provider "azurerm" {
  features {}
  skip_provider_registration = true
}
 
resource "azurerm_resource_group" "example" {
  name     = "azure-resourcegroup"
  location = "West Europe"
}
 
resource "azurerm_virtual_network" "example" {
  name                = "azure-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
 
resource "azurerm_subnet" "example" {
  name                 = "azure-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes       = ["10.0.1.0/24"]
}
 
resource "azurerm_public_ip" "example" {
  name                = "azure-publicip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}
 
resource "azurerm_network_interface" "example" {
  name                = "azure-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}
 
resource "azurerm_linux_virtual_machine" "example" {
  name                = "azure-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  network_interface_ids = [azurerm_network_interface.example.id]
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
 
  computer_name  = "demovm"
  admin_username = "demouser"
  admin_password = "Password1234!"
  disable_password_authentication = false
 
  tags = {
    environment = "staging"
  }
}
