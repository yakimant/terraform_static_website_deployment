variable "aws_region" {
  type = string
}

variable "website_root" {
  type = string
}

variable "workspace_iam_roles" {
  type = map(string)
}

variable "ssh_public_keys" {
  type = map(string)
}

variable "ssh_private_key_paths" {
  type = map(string)
}