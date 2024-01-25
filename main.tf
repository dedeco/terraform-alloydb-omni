resource "google_compute_network" "vpc_network" {
  name                    = "my-alloydb-omni-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-alloydb-omni-subnet"
  ip_cidr_range = "10.0.1.0/24" 
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_disk" "default" {
  name = "alloydb-omni-data"
  type = "pd-standard"
  zone = "us-central1-a"
  size = "200"
}

resource "google_compute_instance" "default" {
  name         = "alloydb-omni-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  attached_disk {
    source      = google_compute_disk.default.id
    device_name = google_compute_disk.default.name
  }

  metadata_startup_script = "${file("omni_start.sh")}"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      # Include this section to give the VM an external IP address
    }
  }

  # Ignore changes for persistent disk attachments
  lifecycle {
    ignore_changes = [attached_disk]
  }

}