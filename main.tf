data "aws_s3_bucket" "source" {
  bucket = var.source_s3_bucket
}

data "aws_s3_bucket" "destination" {
  bucket = var.destination_s3_bucket
}

# resource "aws_s3_bucket_replication_configuration" "replication" {
#   # Must have bucket versioning enabled first
#   # depends_on = [aws_s3_bucket_versioning.source]

#   role   = aws_iam_role.replication.arn
#   bucket = aws_s3_bucket.source.id

#   rule {
#     id = var.app_name

#     status = "Enabled"

#     destination {
#       bucket        = aws_s3_bucket.destination.arn
#       storage_class = "STANDARD"
#     }
#   }
# }
