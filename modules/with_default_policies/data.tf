data "aws_iam_policy_document" "tvlk_build_ecr_repository_p_doc" {
  statement {
    sid    = "AllowPullAccessTvlkOrg"
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:DescribeRepositories",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"

      values = [
        "${var.aws_org_id}",
      ]
    }
  }

  statement {
    sid    = "AllowCrossAccountPushAccess"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "${var.pd_aws_account_arn}",
      ]
    }

    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]
  }
}

data "template_file" "tvlk_build_ecr_lifecycle_policy" {
  template = "${file("${path.module}/lifecycle.json.tpl")}"

  vars {
    max_number_of_prod_images = "${var.max_number_of_prod_images}"
    max_number_of_dev_images  = "${var.max_number_of_dev_images}"
  }
}
