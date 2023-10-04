## Service account variables

variable "credentials" {
  type    = string
  default = "../terraform-service-key.json"
}

variable "client_email" {
  type    = string
  default = "995430163323-compute@developer.gserviceaccount.com"
}

## Account variables

variable "project" {
  type    = string
  default = "dfpl-playground"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

## Node variables

variable "chain_name" {
  type    = string
  default = "ethereum"
}

variable "reth_image" {
  type    = string
  default = "ghcr.io/paradigmxyz/reth:v0.1.0-alpha.10"
}

variable "lighthouse_image" {
  type    = string
  default = "sigp/lighthouse:v4.5.0"
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = true
}

variable "reth_machine_type" {
  type = string
  # while v0.1.0-alpha.10 syncing is still single threaded, serving RPC requests is multi threaded
  # so more core offers better performances (excluding the bootstrapping process)
  default = "n2-standard-8"
}

variable "lighthouse_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "reth_vm_tags" {
  description = "Additional network tags for the reth instances."
  type        = list(string)
  default     = ["reth-auth-rpc", "reth-http-rpc", "reth-ws-rpc", "reth-p2p", "reth-metrics"]
}

variable "lighthouse_vm_tags" {
  description = "Additional network tags for the reth instances."
  type        = list(string)
  default     = ["lighthouse-rpc", "lighthouse-p2p-udp", "lighthouse-p2p", "lighthouse-metrics"]
}

variable "bootstrap" {
  description = "Set true to start syncing the reth node from scratch using raid0 local NVMe SSD"
  type        = bool
  default     = true
}

variable "create_backup_bucket" {
  description = "Set true to create a bucked for node backup."
  type        = bool
  default     = true
}

variable "reth_datadir_disk_size" {
  description = "Reth persistent SSD disk size in GB."
  type        = number
  default     = 2500
}

variable "lighthouse_datadir_disk_size" {
  description = "Lighthouse persistent SSD disk size in GB."
  type        = number
  default     = 1000
}

variable "datadir_path" {
  description = "Consumed by both Reth and Lighthouse on their respective containers."
  type        = string
  default     = "/mnt/datadir"
}

variable "datadir_host_path" {
  description = "Consumed by both Reth and Lighthouse on their respective VMs."
  type        = string
  default     = "/mnt/disks/sdb"
}

variable "datadir_host_local_ssd_path" {
  description = "Consumed by Reth VM when bootstrapping the node from scratch, refs var.bootstrap."
  type        = string
  default     = "/mnt/disks/md0"
}

variable "reth_datadir_disk_snapshot" {
  description = "Deploy the datadir disk from a snapshot unless empty."
  type        = string
  default     = null
}

variable "reth_rpc_source_range" {
  description = "Allowed IP source range for (unauthenticated) RPC related call."
  type        = list(string)
  default = [
    "0.0.0.0/0",
  ]
}

variable "checkpoint_sync_url" {
  description = "https://eth-clients.github.io/checkpoint-sync-endpoints/#mainnet"
  type        = string
  default     = "https://beaconstate-mainnet.chainsafe.io"
}

variable "genesis_beacon_api_url" {
  description = "https://eth-clients.github.io/checkpoint-sync-endpoints/#mainnet"
  type        = string
  default     = "https://beaconstate-mainnet.chainsafe.io"
}

variable "nodes" {
  type = list(string)
  default = [
    "node1",
  ]
}

locals {
  service_name = "reth-infra"
  reth_custom_args = [
    "node",
    "--datadir",
    var.datadir_path,
    "--http",
    "--ws",
    "--http.addr",
    "0.0.0.0",
    "--ws.addr",
    "0.0.0.0",
    "--authrpc.addr",
    "0.0.0.0",
    "--metrics",
    "0.0.0.0:9001",
  ]
  lighthouse_base_custom_args = [
    "lighthouse",
    "beacon",
    "--network",
    "mainnet",
    "--http",
    "--http-address",
    "0.0.0.0",
    "--datadir",
    var.datadir_path,
    "--execution-jwt-secret-key",
    data.google_secret_manager_secret_version.jwt_hex.secret_data,
    "--checkpoint-sync-url",
    var.checkpoint_sync_url,
  ]
  lighthouse_custom_args_map = {
    for node in var.nodes :
    node => concat(
      local.lighthouse_base_custom_args, [
        "--execution-endpoint",
        "http://${module.reth_archive_node_vm[node].google_compute_instance_ip}:8551",
      ]
    )
  }
  # 8 disks of 375G each for a 3T raid0
  scratch_disk_count     = var.bootstrap ? 8 : 0
  reth_datadir_disk_size = var.bootstrap ? 0 : var.reth_datadir_disk_size
  volume_mounts = [
    {
      mountPath = var.datadir_path
      name      = "datadir"
      readOnly  = false
    },
  ]
  prysm_volumes = [
    {
      name = "datadir"
      hostPath = {
        path = var.datadir_host_path
      }
    },
  ]
  reth_volumes = [
    {
      name = "datadir"
      hostPath = {
        path = var.bootstrap ? var.datadir_host_local_ssd_path : var.datadir_host_path
      }
    },
  ]
}
