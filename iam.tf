resource "aws_iam_role" "replication" {
  provider              = aws.source_bucket
  name                  = var.role_name
  permissions_boundary  = var.role_permissions_boundary_arn
  force_detach_policies = var.force_detach_policies
  path                  = var.role_path
  assume_role_policy    = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "replication" {
  provider = aws.source_bucket
  name     = "s3-bucket-replication"
  path     = var.role_path
  policy   = data.aws_iam_policy_document.replication.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [module.source_s3_bucket.s3_buckets[var.source_bucket.name].arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${module.source_s3_bucket.s3_buckets[var.source_bucket.name].arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${module.destination_s3_bucket.s3_buckets[var.destination_bucket.name].arn}/*"]
  }
}

resource "aws_iam_policy_attachment" "replication" {
  provider   = aws.source_bucket
  name       = "s3-bucket-replication-${var.replication_rule_name}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}
