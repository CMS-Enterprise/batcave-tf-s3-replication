variable "source_s3_bucket_arn" {
  description = "Source s3 bucket"
  type        = string
  nullable    = false
}

variable "destination_s3_bucket_arn" {
  description = "Destination s3 bucket"
  type        = string
  nullable    = false
}
