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
  default = "ghcr.io/paradigmxyz/reth:v0.1.0-alpha.4"
}

variable "lighthouse_image" {
  type    = string
  default = "sigp/lighthouse:v4.3.0"
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = true
}

variable "reth_machine_type" {
  type    = string
  default = "e2-standard-4"
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

variable "jwt_hex_path" {
  type    = string
  default = "/etc/jwt.hex"
}

variable "jwt_hex_host_path" {
  type    = string
  default = "/mnt/stateful_partition/etc/jwt.hex"
}

variable "reth_datadir_disk_size" {
  type    = number
  default = 2500
}

variable "lighthouse_datadir_disk_size" {
  type    = number
  default = 100
}

# consumed by both reth and lighthouse on their respective containers
variable "datadir_path" {
  type    = string
  default = "/mnt/datadir"
}

# consumed by both reth and lighthouse on their respective VMs
variable "datadir_host_path" {
  type    = string
  default = "/mnt/disks/sdb"
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

variable "reth_nodes" {
  type    = list(string)
  default = ["node1"]
}

variable "lighthouse_nodes" {
  type    = list(string)
  default = ["node1"]
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
  lighthouse_custom_args = [
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
    "--execution-endpoint",
    "http://${module.reth_archive_node_vm["node1"].google_compute_instance_ip}:8551",
    "--checkpoint-sync-url",
    var.checkpoint_sync_url,
  ]

  volume_mounts = [
    {
      mountPath = var.jwt_hex_path
      name      = "jwt_hex"
      readOnly  = true
    },
    {
      mountPath = var.datadir_path
      name      = "datadir"
      readOnly  = false
    },
  ]
  volumes = [
    {
      name = "jwt_hex"
      hostPath = {
        path = var.jwt_hex_host_path
      }
    },
    {
      name = "datadir"
      hostPath = {
        path = var.datadir_host_path
      }
    },
  ]
}
