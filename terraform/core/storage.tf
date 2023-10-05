resource "google_storage_bucket" "backup-bucket" {
  count         = var.create_backup_bucket ? 1 : 0
  name          = "${local.service_name}-backup-bucket"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  labels = {
    prefix       = local.service_name
    service_name = local.service_name
  }
}
