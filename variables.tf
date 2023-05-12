variable "aws_region" {
  type = string
}

variable "website_root" {
  type    = string
  default = "website"
}

variable "workspace_iam_role" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key" {
  type = string
}