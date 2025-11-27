terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

provider "aws" {
  region                   = var.region
  alias                    = var.source_alias
  profile                  = var.source_profile
  shared_config_files      = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files
}

provider "aws" {
  region                   = var.region
  alias                    = var.target_alias
  profile                  = var.target_profile
  shared_config_files      = var.shared_config_files
  shared_credentials_files = var.shared_credentials_files
}

data "aws_iam_policy_document" "target" {
  provider = aws[var.target_alias]

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = concat(
        [for v in var.source_group_identifiers : v.arn],
        [for v in var.source_role_identifiers : v.arn]
      )
    }
  }
}

data "aws_iam_policy_document" "source" {
  provider = aws[var.source_alias]

  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.target.arn]
  }
}

resource "aws_iam_policy" "target" {
  for_each = {
    for v in var.policy_document_list : v.name => v
  }

  provider    = aws[var.target_alias]
  name        = each.value.name
  path        = "/oph/"
  description = "Assume role policy"
  policy      = each.value.policy
}

resource "aws_iam_role" "target" {
  provider           = aws[var.target_alias]
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.target.json
  managed_policy_arns = [
    for v in aws_iam_policy.target : v.arn
  ]
}

resource "aws_iam_policy" "source" {
  provider = aws[var.source_alias]
  name     = var.name
  path     = "/"
  policy   = data.aws_iam_policy_document.source.json
}

resource "aws_iam_group_policy_attachment" "source_to_target" {
  count      = length(var.source_group_identifiers)
  provider   = aws[var.source_alias]
  group      = var.source_group_identifiers[count.index].name
  policy_arn = aws_iam_policy.source.arn
}

resource "aws_iam_role_policy_attachment" "source_to_target" {
  count      = length(var.source_role_identifiers)
  provider   = aws[var.source_alias]
  role       = var.source_role_identifiers[count.index].name
  policy_arn = aws_iam_policy.source.arn
}
