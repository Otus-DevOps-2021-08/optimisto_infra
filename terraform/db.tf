resource "yandex_compute_instance" "db" {
  #   count = var.backends_count
  name = "reddit-db"
  labels = {
    tags = "reddit-db"
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.db_disk_image
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.app-subnet.id
    nat       = true
  }

  connection {
    type        = "ssh"
    host        = self.network_interface.0.nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }

  #   provisioner "file" {
  #     source      = "../packer/files/reddit.service"
  #     destination = "/tmp/puma.service"
  #   }

  #   provisioner "remote-exec" {
  #     script = "./files/deploy.sh"
  #   }
}
