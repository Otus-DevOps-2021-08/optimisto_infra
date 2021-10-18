  resource "yandex_lb_target_group" "app-target-group" {
  region_id = "ru-central1"

  dynamic "target" {
    for_each = yandex_compute_instance.app
    content {
    subnet_id = target.value.network_interface.0.subnet_id
    address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "load-balancer" {
  listener {
    name = "listener"
    port = var.app_port
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_lb_target_group.app-target-group.id}"

    healthcheck {
      name = "http"
      http_options {
        port = var.app_port
      }
    }
  }
}
