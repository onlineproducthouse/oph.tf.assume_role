# a second provider must be added for the target account
provider "aws" {
  alias  = "source"
  region = "us-east-1"
}

module "assume_role" {
  source = "./.."

  name   = "source-to-target"
  region = local.region

  providers = {
    aws.source = aws.source
    aws.target = aws.source # set to target account provider
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

locals {
  region                   = "us-east-1"
  source_profile           = "source"
  target_profile           = "target"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
