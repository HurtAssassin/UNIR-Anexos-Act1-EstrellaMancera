packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "nginx_node_base" {
  region          = var.aws_region
  ami_name        = "nginx-node-base-{{timestamp}}"
  ami_description = "Ubuntu 20.04 with Nginx and Node.js built with Packer by Estrella Mancera"
  instance_type   = "t2.micro"

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical (Ubuntu)
  }

  ssh_username = "ubuntu"

  tags = {
    Name        = "nginx-node-base"
    Environment = "dev"
    Project     = "Act1 Despliegue de Nginx y Nodejs"
  }
}

build {
  name    = "nginx-node-build"
  sources = ["source.amazon-ebs.nginx_node_base"]

  provisioner "shell" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nginx",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt install -y nodejs",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]
  }
}