provider "aws" {
  alias   = "non-prod"
  region  = "us-east-1"
  profile = var.destination_bucket_profile
}

data "aws_s3_bucket" "source" {
  bucket = var.source_s3_bucket
}

data "aws_s3_bucket" "destination" {
  provider = aws.non-prod
  bucket   = var.destination_s3_bucket
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  # depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = data.aws_s3_bucket.source.arn

  rule {
    id = var.app_name

    status = "Enabled"

    destination {
      bucket        = data.aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
