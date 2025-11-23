source "azure-arm" "nginx-node" {
  use_azure_cli_auth = true

  managed_image_name                = "nginx-node-image"
  managed_image_resource_group_name = var.azure_resource_group
  location                          = var.azure_location

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "18_04-lts-gen2"

  vm_size = "Standard_DC1ds_v3"
}