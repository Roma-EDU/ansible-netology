# Provider https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}