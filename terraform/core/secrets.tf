resource "google_project_service" "secretmanager" {
  provider = google
  service  = "secretmanager.googleapis.com"
}

# JWT Token used for the authentication between the beacon node and the execution node.
# Generate with:
# openssl rand -hex 32
# Refs:
# https://lighthouse-book.sigmaprime.io/run_a_node.html#step-1-create-a-jwt-secret-file
data "google_secret_manager_secret_version" "jwt_hex" {
  secret     = "${local.service_name}-jwt-hex-mainnet"
  version    = "latest"
  depends_on = [google_project_service.secretmanager]
}

