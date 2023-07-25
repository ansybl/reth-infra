output "reth" {
  value = values(module.reth_archive_node_vm).*.google_compute_instance_name_ip_map
}

output "lighthouse" {
  value = values(module.lighthouse_node_vm).*.google_compute_instance_name_ip_map
}

output "reth_ip" {
  value = values(module.reth_archive_node_vm).*.google_compute_instance_ip
}

output "lighthouse_ip" {
  value = values(module.lighthouse_node_vm).*.google_compute_instance_ip
}
