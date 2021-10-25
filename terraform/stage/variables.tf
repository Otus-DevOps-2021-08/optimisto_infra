variable "cloud_id" {
  description = "Cloud"
}

variable "folder_id" {
  description = "Folder"
}

variable "zone" {
  description = "Zone"
  default     = "ru-central1-a"
}

variable "public_key_path" {
  description = "Path to the public key used for ssh access"
}

variable "app_disk_image" {
  description = "Disk image id for reddit app"
}

variable "db_disk_image" {
  description = "Database image id for reddit app"
}

variable "subnet_id" {
  description = "Subnet"
}

variable "service_account_key_file" {
  description = "key .json"
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "app_port" {
  description = "Application port"
  default     = 9292
}
