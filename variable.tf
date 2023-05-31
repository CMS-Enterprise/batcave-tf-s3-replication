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

variable "destination_bucket_profile" {
  description = "The aws profile that the destination bucket is in"
  type        = string
  nullable    = false
}

variable "role_permissions_boundary_arn" {
  description = "Permissions boundary ARN to use for IAM role"
  type        = string
  default     = "arn:aws:iam::568826666399:policy/cms-cloud-admin/developer-boundary-policy"
}

variable "force_detach_policies" {
  description = "Whether policies should be detached from this role when destroying"
  type        = bool
  default     = true
}

variable "role_name" {
  description = "Name of IAM role"
  type        = string
  default     = ""
}

variable "role_path" {
  description = "Path of IAM role"
  type        = string
  default     = "/delegatedadmin/developer/"
}
