# ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1gjn3v7sno758hjjba0"
}

# Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1gr1vdb5g3ktr8v0877"
}

# ID образа
# ID можно узнать с помощью команды yc compute image list
# Или взять из списка существующих https://console.cloud.yandex.ru/folders/b1gr1vdb5g3ktr8v0877/compute/create-instance
# нажав на i и прокрутив вниз до image_id
variable "os_image_id" {
  default = "fd8p7vi5c5bbs2s5i67s"
}

variable "os_user" {
  default = "vagrant"
}

variable "yandex_zone" {
  default = "ru-central1-a"
}