terraform {
  required_version = ">= 1.0"
  backend "local" {}
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "dtc-de-storage-bucket" {
  name     = var.storage_name
  location = var.region

  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30 # days
    }
  }

  force_destroy = true
}

# Data Warehouse
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
resource "google_bigquery_dataset" "dtc-de-bq-dataset" {
  dataset_id = var.bq_dataset
  project    = var.project
  location   = var.region
}

# Google Compute Engine Instance Resource
resource "google_compute_instance" "dtc-de-compute-instance" {
  desired_status = var.compute_status
  name           = var.virtual_machine_name
  zone           = var.zone
  project        = var.project
  machine_type   = var.machine_type
  labels         = var.labels
  tags           = var.tags
  metadata = {
    "status-uptime-deadline" = "420"
    "status-variable-path"   = "status"
  }

  boot_disk {
    device_name = var.virtual_machine_name
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }
  }



  network_interface {
    network            = var.network
    subnetwork         = var.subnetwork
    subnetwork_project = var.project

    access_config {
    }
  }



  service_account {
    email  = var.service_account_email
    scopes = var.service_account_scopes
  }

}

