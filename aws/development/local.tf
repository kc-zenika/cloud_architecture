terraform {
  required_version = ">= 1.0"

  # local provider
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# locals are like private variables
locals {
  filename = "${path.module}/example.txt"
}

# variables, to pass in some inputs
variable "some_content" {
  type = string
  default = "Hello"
}

# local_* uses the local provider
resource "local_file" "example" {
  filename = local.filename
  content  = "This creates a file with ${var.some_content}"

  # other parameters u are passing into this resource
  file_permission      = "0644"
  directory_permission = "0755"
}

# outputs are use to display info (and share data between "modules" - part 2)
output "filename" {
  description = "The name of file that u created"
  value       = local_file.example.filename
}