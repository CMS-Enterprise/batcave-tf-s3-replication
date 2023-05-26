variable "source_s3_bucket" {
  description = "Source s3 bucket"
  type        = string
  nullable    = false
}

variable "destination_s3_bucket" {
  description = "Destination s3 bucket"
  type        = string
  nullable    = false
}

variable "app_name" {
  description = "App Name"
  type        = string
  nullable    = false
}
