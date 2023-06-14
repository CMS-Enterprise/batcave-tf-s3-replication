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
  source = "/home/austin/code/cms/batcave-tf-buckets"
  providers = {
    aws = aws.source_bucket
  }
  s3_bucket_names = [
    var.source_bucket.name
  ]
  sse_algorithm = "AES256"
  force_destroy = true

  versioning_enabled = true
}

module "destination_s3_bucket" {
  source = "/home/austin/code/cms/batcave-tf-buckets"
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
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws.source_bucket
  role     = aws_iam_role.replication.arn
  bucket   = module.source_s3_bucket.s3_buckets[var.source_bucket.name].id

  rule {
    id = var.app_name

    status = "Enabled"

    # filter {
    #   #prefix = "rds-dump"
    # }
    # delete_marker_replication {
    #     status = "Enabled"
    # }
    destination {
      bucket        = module.destination_s3_bucket.s3_buckets[var.destination_bucket.name].arn
      storage_class = "STANDARD"
    }
  }
}
### All of our AWS billing costs are going to go into an s3 budgets. Currently we can't feed into a specific account
### We want all of the batcave accounts to feed cost into one bucket

# Need to be able to support
