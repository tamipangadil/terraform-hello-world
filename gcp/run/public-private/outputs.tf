output "default_service_account" {
  value = google_service_account.default.email
}

output "public_name" {
  value = google_cloud_run_v2_service.public.name
}

output "public_uri" {
  value = google_cloud_run_v2_service.public.uri
}

output "public_location" {
  value = google_cloud_run_v2_service.public.location
}

output "public_project" {
  value = google_cloud_run_v2_service.public.project
}

output "private_name" {
  value = google_cloud_run_v2_service.private.name
}

output "private_uri" {
  value = google_cloud_run_v2_service.private.uri
}

output "private_location" {
  value = google_cloud_run_v2_service.private.location
}

output "private_project" {
  value = google_cloud_run_v2_service.private.project
}
