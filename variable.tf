variable "replication_rule_name" {
  description = "This will be used to name the replication rule and appended to the iam role and policy"
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
    s3_bucket_kms_key_id            = optional(string, null)
    bucket_profile                  = string
    specific_bucket_tags            = optional(map(any), {})
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
    s3_bucket_kms_key_id            = optional(string, null)
    bucket_profile                  = string
    specific_bucket_tags            = optional(map(any), {})
  })
}

variable "common_bucket_tags" {
  type    = map(any)
  default = {}
}

variable "prefix_filter" {
  type        = string
  default     = ""
  description = "The prefix a file needs to be copied over. Also works on folders. So if the prefix is hello and you have a folder called hello all files in the hello folder will replicate"
}

variable "delete_marker_replication" {
  type    = string
  default = "Enabled"

  validation {
    condition     = var.delete_marker_replication == "Enabled" || var.delete_marker_replication == "Disabled"
    error_message = "Invalid value for delete_marker_replication. Only 'Enabled' or 'Disabled' are allowed."
  }
}
