variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "app_disk_image" {
  description = "Disk image id for reddit app"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "user" {
  description = "Username to access instance via SSH"
  default = "ubuntu"
}
