module "assume_role" {
  source = "./.."

  name   = "source-to-target"
  region = local.region

  providers = {
    aws.source = aws.default
    aws.target = aws.default
  }

  source_user_identifiers = [
    { name = "user-name", arn = "iam-user-arn" }
  ]

  source_role_identifiers = [
    { name = "role-name", arn = "iam-role-arn" }
  ]

  policy_document_list = [
    {
      name = "policy-name"

      policy_json_str = jsonencode({
        Version   = "2012-10-17",
        Statement = []
      })
    }
  ]
}

provider "aws" {
  alias  = "default"
  region = "us-east-1"
}

locals {
  region                   = "us-east-1"
  source_profile           = "ophadmin"
  target_profile           = "default"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
