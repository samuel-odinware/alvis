variable "project" {
  description = "GCP Project ID"
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  type        = string
}

variable "zone" {
  description = "The default zone to manage resources in."
  type        = string
}

variable "api_version" {
  description = "GCP API version."
  type        = string
  default     = "v1"
}

variable "network" {
  description = "The name or self_link of the network to attach this interface to."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The name or self_link of the subnetwork to attach this interface to."
  type        = string
  default     = "default"
}

# Service Account
variable "service_account_email" {
  description = "The service account e-mail address. If not given, the default Google Compute Engine service account is used."
  type        = string
  default     = null
}

variable "service_account_scopes" {
  description = "A list of service scopes. Check https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes for a list of scopes."
  type        = list(any)
}

# BigQuery
variable "bq_dataset" {
  description = "A unique ID for this dataset, without the project name. The ID must contain only letters (a-z, A-Z), numbers (0-9), or underscores (_). The maximum length is 1,024 characters."
  type        = string
}

# Compute
variable "virtual_machine_name" {
  description = "Name of virtual machine instance."
  type        = string
}

variable "image" {
  description = "The image from which to initialize this disk. Check https://cloud.google.com/compute/docs/images for more info."
  type        = string
}

variable "disk_size" {
  description = "The size of the image in gigabytes."
  type        = number
}

variable "disk_type" {
  description = "The GCE disk type. May be set to pd-standard, pd-balanced or pd-ssd."
  type        = string
  default     = "pd-balanced"
}

variable "machine_type" {
  description = "The machine type to create."
  type        = string
}

variable "disable-legacy-endpoints" {
  default = null
}

variable "tags" {
  description = "A list of network tags to attach to the instance."
  type        = list(any)
  default     = []
}

variable "labels" {
  description = "A map of key/value label pairs to assign to the instance."
  type        = map(any)
  default     = {}
}

variable "compute_status" {
  description = "Desired status of the instance. Either 'RUNNING' or 'TERMINATED'."
  default     = "RUNNING"
}

# Storage
variable "storage_name" {
  description = "The name of the bucket."
  type        = string
}

variable "storage_class" {
  description = "The Storage Class of the new bucket. Check https://cloud.google.com/storage/docs/storage-classes for more info."
  type        = string
  default     = "STANDARD"
}

