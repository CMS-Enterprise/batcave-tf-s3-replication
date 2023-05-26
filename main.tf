data "aws_s3_bucket" "source_bucket" {
  bucket = var.source_s3_bucket_arn
}

data "aws_s3_bucket" "destination_bucket" {
  bucket = var.destination_s3_bucket_arn
}

resource "aws_s3_bucket_replication_configuration" "replication" {
  # Must have bucket versioning enabled first
  # depends_on = [aws_s3_bucket_versioning.source]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.source.id

  rule {
    id = var.app_name

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.destination.arn
      storage_class = "STANDARD"
    }
  }
}
