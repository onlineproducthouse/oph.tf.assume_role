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

variable "source_user_identifiers" {
  description = "A list of ARNs for source IAM users"
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
