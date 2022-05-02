#Output
output "internal_ip_address_clickhouse_01" {
  value = yandex_compute_instance.clickhouse-01.network_interface.0.ip_address
}

output "internal_ip_address_application_01" {
  value = yandex_compute_instance.application-01.network_interface.0.ip_address
}

output "internal_ip_address_lighthouse_01" {
  value = yandex_compute_instance.lighthouse-01.network_interface.0.ip_address
}


output "external_ip_address_clickhouse_01" {
  value = yandex_compute_instance.clickhouse-01.network_interface.0.nat_ip_address
}

output "external_ip_address_application_01" {
  value = yandex_compute_instance.application-01.network_interface.0.nat_ip_address
}

output "external_ip_address_lighthouse_01" {
  value = yandex_compute_instance.lighthouse-01.network_interface.0.nat_ip_address
}