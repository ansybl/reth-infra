locals {
  env_variables = [for var_name, var_value in var.env_variables : {
    name  = var_name
    value = var_value
  }]
  has_datadir_disk_snapshot = var.datadir_disk_snapshot != null && var.datadir_disk_snapshot != ""
}

####################
##### CONTAINER SETUP

module "gce-container" {
  # https://github.com/terraform-google-modules/terraform-google-container-vm
  source  = "terraform-google-modules/container-vm/google"
  version = "3.1.0"

  container = {
    image        = var.image
    command      = var.custom_command
    args         = var.custom_args
    env          = local.env_variables
    volumeMounts = var.volume_mounts
    securityContext = {
      privileged : var.privileged_mode
    }
    tty : var.activate_tty
  }

  volumes = var.volumes

  restart_policy = "Always"
}

####################
##### COMPUTE ENGINE

resource "google_compute_disk" "boot" {
  name  = "${var.prefix}-${var.instance_name}-boot-disk-${var.suffix}"
  image = module.gce-container.source_image
  size  = 10
  type  = "pd-balanced"
  labels = merge(tomap({
    container-vm  = module.gce-container.vm_container_label,
    instance_name = var.instance_name,
    prefix        = var.prefix,
    }),
    var.labels,
  )
  lifecycle {
    ignore_changes = [
      # we don't want the Container-Optimized OS changes to force a redeployment of our VM without our consent
      image,
    ]
  }
}

data "google_compute_snapshot" "archive_snapshot" {
  # workaround for the name as it cannot be empty
  name = local.has_datadir_disk_snapshot ? var.datadir_disk_snapshot : "no-snapshot"
}

resource "google_compute_disk" "datadir" {
  count    = var.datadir_disk_size > 0 ? 1 : 0
  name     = "${var.prefix}-${var.instance_name}-datadir-disk-${var.suffix}"
  snapshot = local.has_datadir_disk_snapshot ? data.google_compute_snapshot.archive_snapshot.self_link : null
  type     = "pd-balanced"
  # this disk was once restored from a snapshot
  lifecycle {
    ignore_changes = [
      snapshot,
    ]
  }
  size = var.datadir_disk_size
  labels = merge(tomap({
    container-vm  = module.gce-container.vm_container_label,
    instance_name = var.instance_name,
    prefix        = var.prefix,
    }),
    var.labels,
  )
}

resource "google_compute_instance" "this" {
  name         = "${var.prefix}-${var.instance_name}-${var.suffix}"
  machine_type = var.machine_type
  # If true, allows Terraform to stop the instance to update its properties.
  allow_stopping_for_update = true
  tags                      = var.vm_tags

  dynamic "scratch_disk" {
    for_each = range(var.scratch_disk_count)
    content {
      interface = "NVME"
    }
  }

  boot_disk {
    source = google_compute_disk.boot.self_link
  }

  dynamic "attached_disk" {
    for_each = google_compute_disk.datadir.*.self_link
    content {
      source      = attached_disk.value
      device_name = google_compute_disk.datadir.*.name[0]
      mode        = "READ_WRITE"
    }
  }

  network_interface {
    network    = var.network_name
    network_ip = var.create_static_ip ? google_compute_address.static_internal.address : null
    access_config {
      nat_ip = var.create_static_ip ? google_compute_address.static.address : null
    }
  }

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value
    google-logging-enabled    = var.enable_gcp_logging
    google-monitoring-enabled = var.enable_gcp_monitoring
  }

  labels = merge(tomap({
    container-vm  = module.gce-container.vm_container_label,
    prefix        = var.prefix
    instance_name = var.instance_name,
    prefix        = var.prefix,
    }),
    var.labels,
  )

  service_account {
    email = var.client_email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  lifecycle {
    ignore_changes = [
      # we don't want the Container-Optimized OS changes to force a redeployment of our VM without our consent
      boot_disk[0].initialize_params[0].image,
      # VM that are already up running shouldn't be impacted by startup script updates
      metadata_startup_script,
    ]
  }

  metadata_startup_script = var.metadata_startup_script
}
