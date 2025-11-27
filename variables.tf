variable "name" {
  description = "Module name"
  type        = string
  nullable    = false
}

variable "region" {
  description = "AWS region"
  type        = string
  nullable    = false
}

variable "source_profile" {
  description = "Source account profile"
  type        = string
  nullable    = false
}

variable "target_profile" {
  description = "Target account profile"
  type        = string
  nullable    = false
}

variable "shared_config_files" {
  description = "Path to aws config file"
  type        = list(string)
  default     = ["~/.aws/config"]
  nullable    = false
}

variable "shared_credentials_files" {
  description = "Path to aws credentials file"
  type        = list(string)
  default     = ["~/.aws/credentials"]
  nullable    = false
}

variable "source_group_identifiers" {
  description = "A list of ARNs for source IAM groups"
  default     = []
  nullable    = false

  type = list(object({
    name = string
    arn  = string
  }))
}

variable "source_role_identifiers" {
  description = "A list of ARNs for source IAM roles"
  default     = []
  nullable    = false

  type = list(object({
    name = string
    arn  = string
  }))
}

variable "policy_document_list" {
  description = "A list of IAM policies"
  default     = []
  type = list(object({
    name            = string
    policy_json_str = string
  }))
}
