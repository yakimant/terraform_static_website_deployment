Experimentation repository, don't use in production.

The specifics of this solution is, that it deploys the website files in Terraform.

# Requirements
## AWS
- Admin, Dev and Prod accounts
- Terraform user in Admin account (can assume roles)
- Dev and Prod Terraform roles for Admin Terraform user
- Terraform Cloud
  - Create dev and prod workspaces
  - Disable remote execution for them
## Local
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Terraform Cloud Login](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS CLI Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html) (or pass keys to Terraform as ENV variables)
  - terraform get -update

# Run
- `terraform init`
- `terraform apply`

# Improvements
- File provisioner
  - Downsides
    - needs SSH access (network & keys)
    - Doesn't remove files
    - Not in sync with the state file

# Alternative solutions
- Deploy files separately in CI/CD
- Checkout git on EC2

# TODO
- Variable descriptions & checks
- Resources names and tags normalize
- Remove files on EC2, when removed locally
- CI (GitHub Actions or Terraform Cloud)
- Custom DNS CNAME for CloudFront
- Separate, non-default VPCs for Dev and Prod EC2