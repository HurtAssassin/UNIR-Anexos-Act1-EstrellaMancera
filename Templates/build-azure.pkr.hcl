build {
  name    = "nginx-node-build-azure"
  sources = ["source.azure-arm.nginx-node"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx nodejs -y",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}