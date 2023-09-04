variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "europe-west2"
}
