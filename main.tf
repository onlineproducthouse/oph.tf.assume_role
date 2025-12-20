terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "6.23.0"
      configuration_aliases = [aws.source, aws.target]
    }
  }
}

data "aws_iam_policy_document" "target" {
  provider = aws.target

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
  provider = aws.source

  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.target.arn]
  }
}

resource "aws_iam_policy" "target" {
  for_each = {
    for v in var.policy_document_list : v.name => v
  }

  provider    = aws.target
  name        = each.value.name
  path        = "/oph/"
  description = "Assume role policy"
  policy      = each.value.policy_json_str
}

resource "aws_iam_role" "target" {
  provider           = aws.target
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.target.json
}

resource "aws_iam_role_policy_attachment" "target" {
  for_each = {
    for v in aws_iam_policy.target : v.name => v
  }

  provider   = aws.target
  role       = aws_iam_role.target.name
  policy_arn = each.value.arn
}

resource "aws_iam_policy" "source" {
  provider = aws.source
  name     = var.name
  path     = "/"
  policy   = data.aws_iam_policy_document.source.json
}

resource "aws_iam_group_policy_attachment" "source_to_target" {
  count      = length(var.source_group_identifiers)
  provider   = aws.source
  group      = var.source_group_identifiers[count.index].name
  policy_arn = aws_iam_policy.source.arn
}

resource "aws_iam_role_policy_attachment" "source_to_target" {
  count      = length(var.source_role_identifiers)
  provider   = aws.source
  role       = var.source_role_identifiers[count.index].name
  policy_arn = aws_iam_policy.source.arn
}
