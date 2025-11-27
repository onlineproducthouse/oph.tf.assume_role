module "assume_role" {
  source = "./.."

  name   = "source-to-target"
  region = local.region

  source_profile = local.source_profile
  target_profile = local.target_profile

  shared_config_files      = local.shared_config_files
  shared_credentials_files = local.shared_credentials_files

  source_group_identifiers = [
    { name = "group-name", arn = "iam-group-arn" }
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
  source_profile           = "ophadmin"
  target_profile           = "default"
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
}
