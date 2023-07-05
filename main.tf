terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.61.0"
    }
  }
  required_version = ">= 1.2"
}

provider "aws" {
  alias   = "destination_bucket"
  region  = "us-east-1"
  profile = var.destination_bucket.bucket_profile
}

provider "aws" {
  alias   = "source_bucket"
  region  = "us-east-1"
  profile = var.source_bucket.bucket_profile
}


module "source_s3_bucket" {
  source = "git::https://code.batcave.internal.cms.gov/batcave-iac/batcave-tf-buckets.git?ref=0.4.0"
  providers = {
    aws = aws.source_bucket
  }
  s3_bucket_names = [
    var.source_bucket.name
  ]
  versioning_enabled   = true
  sse_algorithm        = var.source_bucket.sse_algorithm
  force_destroy        = var.source_bucket.force_destroy
  s3_bucket_kms_key_id = var.source_bucket.s3_bucket_kms_key_id
  tags                 = merge(var.common_bucket_tags, var.source_bucket.specific_bucket_tags)
}

module "destination_s3_bucket" {
  source = "git::https://code.batcave.internal.cms.gov/batcave-iac/batcave-tf-buckets.git?ref=0.4.0"
  providers = {
    aws = aws.destination_bucket
  }
  s3_bucket_names = [
    var.destination_bucket.name
  ]

  versioning_enabled              = true
  sse_algorithm                   = var.destination_bucket.sse_algorithm
  force_destroy                   = var.destination_bucket.force_destroy
  s3_bucket_kms_key_id            = var.destination_bucket.s3_bucket_kms_key_id
  tags                            = merge(var.common_bucket_tags, var.destination_bucket.specific_bucket_tags)
  replication_permission_iam_role = aws_iam_role.replication.arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [module.source_s3_bucket.bucket_verisioning, module.destination_s3_bucket.bucket_versioning]
  provider   = aws.source_bucket
  role       = aws_iam_role.replication.arn
  bucket     = module.source_s3_bucket.s3_buckets[var.source_bucket.name].id

  rule {
    id = var.replication_rule_name

    filter {
      prefix = var.prefix_filter
    }

    delete_marker_replication {
      status = "Enabled"
    }

    status = "Enabled"

    destination {
      bucket        = module.destination_s3_bucket.s3_buckets[var.destination_bucket.name].arn
      storage_class = "STANDARD"
    }
  }
}
