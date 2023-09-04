provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"

  disable_on_destroy = true
}

data "terraform_remote_state" "run_v2_service_public" {
  backend = "local"

  config = {
    path = "../../run/public-private/terraform.tfstate"
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "9.1.0"

  name    = var.lb_name
  project = var.project_id

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl
  labels                          = { "example-label" = "cloud-run-example" }

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn = false

      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = data.terraform_remote_state.run_v2_service_public.outputs.public_name
  }
}

resource "google_cloud_run_service_iam_member" "public-access" {
  location = data.terraform_remote_state.run_v2_service_public.outputs.public_location
  project  = data.terraform_remote_state.run_v2_service_public.outputs.public_project
  service  = data.terraform_remote_state.run_v2_service_public.outputs.public_name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
