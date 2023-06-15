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

#"AWS" : "arn:aws:iam::${data.aws_caller_identity.source_bucket.account_id}:role${var.replication_role_path}${var.replication_role_name}"
locals {
  replication_policy = [
    {
      Sid    = "ReplicaPermissionsFiles"
      Effect = "Allow"
      Principal = {
        "AWS" : "${aws_iam_role.replication.arn}"
      }
      #arn:aws:iam::568826666399:role/delegatedadmin/developer/cybergeek-replication-role
      Action = ["s3:ReplicateObject", "s3:ReplicateDelete", "s3:ReplicateTags"]
      Resource = [
        "arn:aws:s3:::${var.destination_bucket.name}/*",
      ]
    },
    {
      Sid    = "ReplicaPermissions"
      Effect = "Allow"
      Principal = {
        "AWS" : "${aws_iam_role.replication.arn}"
      }
      Action = ["s3:GetReplicationConfiguration", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::${var.destination_bucket.name}",
      ]
    }
  ]
}


module "source_s3_bucket" {
  source = "git::https://code.batcave.internal.cms.gov/batcave-iac/batcave-tf-buckets.git?ref=s3-repliation-changes"
  providers = {
    aws = aws.source_bucket
  }
  s3_bucket_names = [
    var.source_bucket.name
  ]
  versioning_enabled = true
  sse_algorithm      = var.source_bucket.sse_algorithm
  force_destroy      = var.source_bucket.force_destroy
  tags               = merge(var.common_bucket_tags, var.source_bucket.specific_bucket_tags)
}

module "destination_s3_bucket" {
  source = "git::https://code.batcave.internal.cms.gov/batcave-iac/batcave-tf-buckets.git?ref=s3-repliation-changes"
  providers = {
    aws = aws.destination_bucket
  }
  s3_bucket_names = [
    var.destination_bucket.name
  ]

  versioning_enabled    = true
  sse_algorithm         = var.destination_bucket.sse_algorithm
  force_destroy         = var.destination_bucket.force_destroy
  extra_bucket_policies = local.replication_policy
  tags                  = merge(var.common_bucket_tags, var.destination_bucket.specific_bucket_tags)
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [module.source_s3_bucket.bucket_verisioning, module.destination_s3_bucket.bucket_versioning]
  provider   = aws.source_bucket
  role       = aws_iam_role.replication.arn
  bucket     = module.source_s3_bucket.s3_buckets[var.source_bucket.name].id

  rule {
    id = var.replication_rule_name

    filter{
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
