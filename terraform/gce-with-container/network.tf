resource "google_compute_firewall" "allow_tag_reth_auth_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-reth-auth-rpc-${var.suffix}"
  description   = "Ingress to allow reth auth RPC port on VMs with the 'reth-auth-rpc' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reth-auth-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.reth_auth_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_reth_http_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-reth-http-rpc-${var.suffix}"
  description   = "Ingress to allow reth HTTP RPC port on VMs with the 'reth-http-rpc' tag"
  network       = var.network_name
  source_ranges = var.reth_rpc_source_range
  target_tags   = ["reth-http-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.reth_http_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_reth_ws_rpc" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-reth-ws-rpc-${var.suffix}"
  description   = "Ingress to allow reth HTTP WS RPC port on VMs with the 'reth-ws-rpc' tag"
  network       = var.network_name
  source_ranges = var.reth_rpc_source_range
  target_tags   = ["reth-ws-rpc"]
  allow {
    protocol = "tcp"
    ports    = [var.reth_ws_rpc_port]
  }
}

resource "google_compute_firewall" "allow_tag_reth_p2p" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-reth-p2p-${var.suffix}"
  description   = "Ingress to allow reth P2P TCP and UDP port on VMs with the 'reth-p2p' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reth-p2p"]
  allow {
    protocol = "tcp"
    ports    = [var.reth_p2p_port]
  }
  allow {
    protocol = "udp"
    ports    = [var.reth_p2p_port]
  }
}

resource "google_compute_firewall" "allow_tag_reth_metrics" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-reth-metrics-${var.suffix}"
  description   = "Ingress to allow reth metrics port on VMs with the 'reth-metrics' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reth-metrics"]
  allow {
    protocol = "tcp"
    ports    = [var.reth_metrics_port]
  }
}

resource "google_compute_firewall" "allow_tag_lighthouse_p2p_udp" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-lighthouse-p2p-udp-${var.suffix}"
  description   = "Ingress to allow beacon node P2P UDP port on VMs with the 'lighthouse-p2p-udp' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["lighthouse-p2p-udp"]
  allow {
    protocol = "udp"
    ports    = [var.lighthouse_p2p_udp_port]
  }
}

resource "google_compute_firewall" "allow_tag_lighthouse_p2p" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-lighthouse-p2p-${var.suffix}"
  description   = "Ingress to allow beacon node P2P TCP port on VMs with the 'lighthouse-p2p' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["lighthouse-p2p"]
  allow {
    protocol = "tcp"
    ports    = [var.lighthouse_p2p_port]
  }
}

resource "google_compute_firewall" "allow_tag_lighthouse_metrics" {
  count         = var.create_firewall_rule ? 1 : 0
  name          = "${var.prefix}-${var.instance_name}-ingress-tag-lighthouse-metrics-${var.suffix}"
  description   = "Ingress to allow lighthouse metrics port on VMs with the 'lighthouse-metrics' tag"
  network       = var.network_name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["lighthouse-metrics"]
  allow {
    protocol = "tcp"
    ports    = [var.lighthouse_metrics_port]
  }
}

resource "google_compute_address" "static" {
  provider = google-beta
  name     = "${var.prefix}-${var.instance_name}-address-${var.suffix}"
  labels = merge(tomap({
    prefix        = var.prefix
    instance_name = var.instance_name
    }),
  )
}

resource "google_compute_address" "static_internal" {
  provider     = google-beta
  name         = "${var.prefix}-${var.instance_name}-internal-address-${var.suffix}"
  address_type = "INTERNAL"
  labels = merge(tomap({
    prefix        = var.prefix
    instance_name = var.instance_name
    }),
  )
}
