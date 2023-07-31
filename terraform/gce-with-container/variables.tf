variable "prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
}

variable "suffix" {
  type = string
}

variable "network_name" {
  type = string
}

variable "vm_tags" {
  description = "Additional network tags for the instances."
  type        = list(string)
  default     = []
}

variable "enable_gcp_logging" {
  description = "Enable the Google logging agent."
  type        = bool
  default     = true
}

variable "enable_gcp_monitoring" {
  description = "Enable the Google monitoring agent."
  type        = bool
  default     = true
}

variable "create_firewall_rule" {
  description = "Create tag-based firewall rule."
  type        = bool
  default     = false
}

variable "reth_auth_rpc_port" {
  description = "Port for authenticated APIs."
  type        = number
  default     = 8551
}

variable "reth_http_rpc_port" {
  description = "Port for HTTP RPC."
  type        = number
  default     = 8545
}

variable "reth_ws_rpc_port" {
  description = "Port for WS RPC."
  type        = number
  default     = 8546
}

variable "reth_rpc_source_range" {
  description = "Allowed IP source range for (unauthenticated) RPC related call."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "reth_p2p_port" {
  description = "Port for P2P."
  type        = number
  default     = 30303
}

variable "reth_metrics_port" {
  description = "Port for metrics."
  type        = number
  default     = 9001
}

variable "lighthouse_p2p_udp_port" {
  description = "Port used for P2P."
  type        = number
  default     = 9000
}

variable "lighthouse_p2p_port" {
  description = "Port used for P2P."
  type        = number
  default     = 9000
}

variable "lighthouse_metrics_port" {
  description = "Port for metrics."
  type        = number
  default     = 5054
}

variable "datadir_disk_size" {
  description = "Persistent disk size (GB) used for the datadir"
  type        = number
  default     = 100
}

variable "datadir_disk_snapshot" {
  description = "Deploy the datadir disk from a snapshot unless empty."
  type        = string
  default     = null
}

variable "create_static_ip" {
  description = "Create a static IP"
  type        = bool
  default     = false
}

variable "instance_name" {
  description = "The desired name to assign to the deployed instance"
  default     = "disk-instance-vm-test"
}

variable "image" {
  description = "The Docker image to deploy to GCE instances"
}

variable "env_variables" {
  type    = map(string)
  default = null
}

variable "privileged_mode" {
  type    = bool
  default = false
}

# gcloud compute machine-types list | grep micro | grep us-central1-a
# e2-micro / 2 / 1.00
# f1-micro / 1 / 0.60
# gcloud compute machine-types list | grep small | grep us-central1-a
# e2-small / 2 / 2.00
# g1-small / 1 / 1.70
variable "machine_type" {
  type    = string
  default = "f1-micro"
}

variable "activate_tty" {
  type    = bool
  default = false
}

variable "custom_command" {
  type    = list(string)
  default = null
}

variable "custom_args" {
  type    = list(string)
  default = null
}

variable "additional_metadata" {
  type        = map(string)
  description = "Additional metadata to attach to the instance"
  default     = null
}

variable "labels" {
  type        = map(string)
  description = "Additional labels to attach to the instance"
  default     = null
}

variable "client_email" {
  description = "Service account email address"
  type        = string
  default     = null
}

variable "metadata_startup_script" {
  type    = string
  default = ""
}

variable "scratch_disk_count" {
  description = "Number of NVMe SSD disks to use for the raid0"
  type        = number
  default     = 0
}

variable "volume_mounts" {
  type = list(object({
    mountPath = string
    name      = string
    readOnly  = bool
  }))
  default = []
}

variable "volumes" {
  type = list(object({
    name = string,
    hostPath = object({
      path = string,
    })
  }))
  default = []
}
