terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}

provider "google" {
  # Replace `PROJECT_ID` with your project
  project = var.project_id
}

# Enables the Cloud Run API
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

resource "google_project_service" "dns_api" {
  service = "dns.googleapis.com"

  disable_on_destroy = true
}

# [START cloudrun_service_interservice_sa]
resource "google_service_account" "default" {
  account_id   = "cloud-run-interservice-id"
  description  = "Identity used by a public Cloud Run service to call private Cloud Run services."
  display_name = "cloud-run-interservice-id"
}
# [END cloudrun_service_interservice_sa]

# [START cloudrun_interservice_parent_tag]
# [START cloudrun_service_interservice_public_service]
resource "google_cloud_run_v2_service" "public" {
  name     = "public-service"
  location = var.region

  template {
    containers {
      # TODO<developer>: replace this with a public service container
      # (This service can be invoked by anyone on the internet)
      image = "tamipangadil/nodejs-public-service:private"

      # Include a reference to the private Cloud Run
      # service's URL as an environment variable.
      env {
        name  = "PRIVATE_URL"
        value = google_cloud_run_v2_service.private.uri
      }
    }
    # Give the "public" Cloud Run service
    # a service account's identity
    service_account = google_service_account.default.email
  }

  depends_on = [
    google_service_account.default
  ]
}
# [END cloudrun_service_interservice_public_service]

# [START cloudrun_service_interservice_public_policy]
data "google_iam_policy" "public" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "public" {
  location = google_cloud_run_v2_service.public.location
  project  = google_cloud_run_v2_service.public.project
  service  = google_cloud_run_v2_service.public.name

  policy_data = data.google_iam_policy.public.policy_data
}
# [END cloudrun_service_interservice_public_policy]

# [START cloudrun_service_interservice_private_service]
resource "google_cloud_run_v2_service" "private" {
  name     = "private-service"
  location = var.region

  template {
    containers {
      // TODO<developer>: replace this with a private service container
      // (This service should only be invocable by the public service)
      image = "tamipangadil/nodejs-private-service:latest"
    }

  }

  depends_on = [
    google_service_account.default
  ]
}
# [END cloudrun_service_interservice_private_service]

# [START cloudrun_service_interservice_private_policy]
data "google_iam_policy" "private" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.default.email}",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "private" {
  location = google_cloud_run_v2_service.private.location
  project  = google_cloud_run_v2_service.private.project
  service  = google_cloud_run_v2_service.private.name

  policy_data = data.google_iam_policy.private.policy_data
}
# [END cloudrun_service_interservice_private_policy]
# [END cloudrun_interservice_parent_tag]
