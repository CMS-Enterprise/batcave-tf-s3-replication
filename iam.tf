resource "aws_iam_role" "replication" {
  name                  = "${var.app_name}-replication-role"
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
  name   = "s3-bucket-replication-${var.app_name}"
  path   = var.role_path
  policy = data.aws_iam_policy_document.replication.json
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]

    resources = [data.aws_s3_bucket.source.arn]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = ["${data.aws_s3_bucket.source.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${data.aws_s3_bucket.destination.arn}/*"]
  }
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "s3-bucket-replication-${var.app_name}"
  roles      = [aws_iam_role.replication.name]
  policy_arn = aws_iam_policy.replication.arn
}


data "aws_iam_policy_document" "allow_access_from_another_account" {
  provider = aws.destination_bucket
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
    ]

    resources = ["${data.aws_s3_bucket.destination.arn}/*"]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.replication.arn]
    }

    actions = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = ["${data.aws_s3_bucket.destination.arn}"]
  }

  #   statement {
  #     sid    = "EnforceTls"
  #     effect = "Deny"

  #     actions = [
  #       "s3:*"
  #     ]

  #     resources = ["${data.aws_s3_bucket.destination.arn}","${data.aws_s3_bucket.destination.arn}/*"]
  #     condition {
  #       Bool = {
  #         test = "Bool"
  #         variable = "aws:SecureTransport"
  #         values   = ["false"]
  #       }
  #     }
  #   }


  #   Statement = [
  #     {
  #       Sid       = "EnforceTls"
  #       Effect    = "Deny"
  #       Principal = "*"
  #       Action    = "s3:*"
  #       Resource = [
  #         "${data.aws_s3_bucket.destination.arn}/*",
  #         "${data.aws_s3_bucket.destination.arn}",
  #       ]
  #       Condition = {
  #         test = "Bool"
  #         variable = "aws:SecureTransport"
  #         values   = ["false"]
  #       }
  #     },
  #     {
  #       Sid       = "MinimumTlsVersion"
  #       Effect    = "Deny"
  #       Principal = "*"
  #       Action    = "s3:*"
  #       Resource = [
  #         "${each.value.arn}/*",
  #         "${each.value.arn}",
  #       ]
  #       Condition = {
  #         NumericLessThan = {
  #           "s3:TlsVersion" = "1.2"
  #         }
  #       }
  #     },
  #   ]
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  provider = aws.destination_bucket
  bucket   = data.aws_s3_bucket.destination.id
  policy   = data.aws_iam_policy_document.allow_access_from_another_account.json
}
