provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.yandex_zone
}

resource "yandex_compute_instance" "clickhouse-01" {
  name      = "clickhouse-01-server"
  zone      = var.yandex_zone
  hostname  = "clickhouse-01.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.subnet-1.id
    nat        = true
    ip_address = "192.168.10.11"
  }

  metadata = {
    ssh-keys = "${var.os_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "application-01" {
  name      = "application-01-server"
  zone      = var.yandex_zone
  hostname  = "application-01.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    ip_address = "192.168.10.21"
  }

  metadata = {
    ssh-keys = "${var.os_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_compute_instance" "lighthouse-01" {
  name      = "lighthouse-01-server"
  zone      = var.yandex_zone
  hostname  = "lighthouse-01.netology.yc"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
    ip_address = "192.168.10.31"
  }

  metadata = {
    ssh-keys = "${var.os_user}:${file("~/.ssh/id_rsa.pub")}"
  }
}