terraform {
  backend "gcs" {
    bucket  = "terraform-state-yolo194"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = "bigquery-ml-course-457617"
  region  = "me-central1"
}

# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

# compute instance with service account attached.
resource "google_compute_instance" "ci-cd-runner" {
  allow_stopping_for_update = true
  boot_disk {
    auto_delete = true
    device_name = "ci-cd-runner"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2504-plucky-amd64-v20250426"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-medium"
  name         = "ci-cd-runner"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/bigquery-ml-course-457617/regions/me-central1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = google_service_account.ci-cd-sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server", "https-server", "lb-health-check"]
  zone = "me-central1-a"
}

# service account with roles attached to push/pull from artifact registry repo and attach to above instance.
resource "google_service_account" "ci-cd-sa" {
  account_id   = "ci-cd-service-account"
  display_name = "ci-cd"
}

resource "google_project_iam_member" "ci-cd-sa-artifact-registry-push" {
  project = "bigquery-ml-course-457617"
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-artifact-registry-pull-" {
  project = "bigquery-ml-course-457617"
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-cloud-run-deploy" {
  project = "bigquery-ml-course-457617"
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-cloud-service-account-user" {
  project = "bigquery-ml-course-457617"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-cloud-build-editor" {
  project = "bigquery-ml-course-457617"
  role    = "roles/cloudbuild.builds.editor"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-cloud-storage-admin" {
  project = "bigquery-ml-course-457617"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}

resource "google_project_iam_member" "ci-cd-sa-service-usage-consumer" {
  project = "bigquery-ml-course-457617"
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.ci-cd-sa.email}"
}


# artifact registry repository
resource "google_artifact_registry_repository" "my-repo" {
  location      = "me-central1"
  repository_id = "item-yolo-app1"
  description   = "item-app-1"
  format        = "DOCKER"
}

# cloud run function (FaaS)
# resource "google_cloudfunctions2_function" "item-app-faas" {
#   name = "item-app-faas"
#   location = "me-central1"
#   description = "item-app deployed as a serverless faas"

#   build_config {
#     runtime = "python10"
#     entry_point = "hello_world"  # Set the entry point 
#     source {
#       storage_source {
#         bucket = google_storage_bucket.bucket.name
#         object = google_storage_bucket_object.object.name
#       }
#     }
#   }

#   service_config {
#     max_instance_count  = 1
#     available_memory    = "256M"
#     timeout_seconds     = 60
#   }
# }