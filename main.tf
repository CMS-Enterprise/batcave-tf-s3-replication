provider "aws" {
  alias   = "destination_bucket"
  region  = "us-east-1"
  profile = var.destination_bucket_profile
}

data "aws_s3_bucket" "source" {
  bucket = var.source_s3_bucket
}

data "aws_s3_bucket" "destination" {
  provider = aws.destination_bucket
  bucket   = var.destination_s3_bucket
}

resource "aws_s3_bucket_versioning" "source" {
  bucket = data.aws_s3_bucket.source.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "destination" {
  provider = aws.destination_bucket
  bucket   = data.aws_s3_bucket.destination.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.source, aws_s3_bucket_versioning.destination]
  role       = aws_iam_role.replication.arn
  bucket     = data.aws_s3_bucket.source.id

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
      bucket        = data.aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
### All of our AWS billing costs are going to go into an s3 budgets. Currently we can't feed into a specific account
### We want all of the batcave accounts to feed cost into one bucket

# Need to be able to support
