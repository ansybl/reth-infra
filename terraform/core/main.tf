# terraform {
#   backend "gcs" {
#     bucket      = "reth-infra-bucket-tfstate"
#     prefix      = "terraform/state"
#     credentials = "../terraform-service-key.json"
#   }
# }

provider "google" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "default" {
  name          = "${local.service_name}-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

data "local_file" "format_script" {
  filename = "${path.module}/format.sh"
}

module "reth_archive_node_vm" {
  for_each        = toset(var.reth_nodes)
  source          = "../gce-with-container"
  image           = var.reth_image
  custom_args     = local.reth_custom_args
  privileged_mode = true
  activate_tty    = true
  machine_type    = var.reth_machine_type
  prefix          = local.service_name
  suffix          = "mainnet"
  labels = {
    chain        = var.chain_name
    client_type  = "execution"
    network      = "mainnet"
    node         = each.value
    node_type    = "archive_node"
    prefix       = local.service_name
    service_name = local.service_name
  }
  env_variables         = {}
  instance_name         = "reth-${each.value}"
  network_name          = "default"
  create_static_ip      = true
  create_firewall_rule  = var.create_firewall_rule
  reth_rpc_source_range = var.reth_rpc_source_range
  vm_tags               = var.reth_vm_tags
  # This has the permission to download images from Container Registry
  client_email      = var.client_email
  datadir_disk_size = var.reth_datadir_disk_size
  volume_mounts     = local.volume_mounts
  volumes           = local.volumes
  metadata_startup_script = join("\n", [
    data.local_file.format_script.content,
  ])
}

module "lighthouse_node_vm" {
  for_each        = toset(var.lighthouse_nodes)
  source          = "../gce-with-container"
  image           = var.lighthouse_image
  custom_args     = local.lighthouse_custom_args
  privileged_mode = true
  activate_tty    = true
  machine_type    = var.lighthouse_machine_type
  prefix          = local.service_name
  suffix          = "mainnet"
  labels = {
    chain        = var.chain_name
    client_type  = "consensus"
    network      = "mainnet"
    node         = each.value
    node_type    = "archive_node"
    prefix       = local.service_name
    service_name = local.service_name
  }
  env_variables    = {}
  instance_name    = "lighthouse-${each.value}"
  network_name     = "default"
  create_static_ip = true
  vm_tags          = var.lighthouse_vm_tags
  # This has the permission to download images from Container Registry
  client_email      = var.client_email
  datadir_disk_size = var.lighthouse_datadir_disk_size
  volume_mounts     = local.volume_mounts
  volumes           = local.volumes
  metadata_startup_script = join("\n", [
    data.local_file.format_script.content,
  ])
}
