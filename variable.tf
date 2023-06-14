variable "app_name" {
  description = "App Name"
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

variable "source_bucket" {
  type = object({
    name                            = string
    lifecycle_expiration_days       = optional(number, 0)
    force_destroy                   = optional(bool, true)
    is_replication_target           = optional(bool, false)
    replication_target_iam_role_arn = optional(string, null)
    sse_algorithm                   = optional(string, "aws:kms")
    bucket_profile                  = string
  })
}

variable "destination_bucket" {
  type = object({
    name                            = string
    lifecycle_expiration_days       = optional(number, 0)
    force_destroy                   = optional(bool, true)
    is_replication_target           = optional(bool, false)
    replication_target_iam_role_arn = optional(string, null)
    sse_algorithm                   = optional(string, "aws:kms")
    bucket_profile                  = string
  })
}
