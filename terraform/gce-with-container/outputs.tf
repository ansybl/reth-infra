output "google_compute_instance_ip" {
  description = "The IP of the compute instance"
  value       = try(google_compute_instance.this.network_interface.0.access_config.0.nat_ip, "")
}

output "google_compute_instance_name_ip_map" {
  description = "The name and the IP of the compute instance"
  value = {
    (google_compute_instance.this.name) : google_compute_instance.this.network_interface.0.access_config.0.nat_ip
  }
}
