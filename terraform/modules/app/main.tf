resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  labels = {
    tags = "reddit-app"
  }

  metadata = {
    ssh-keys = "${var.user}:${file(var.public_key_path)}"
  }

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  connection {
    type        = "ssh"
    host        = self.network_interface.0.nat_ip_address
    user        = var.user
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sed -i 's/%DATABASE_URL%/${var.database_url}/g' /tmp/puma.service"
    ]
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }
}
