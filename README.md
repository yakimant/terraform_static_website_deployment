Experimentation repository, don't use in production.

The specifics of this solution is, that it deploys the website files in Terraform.

# Requirements
## AWS & Terraform Cloud
- Admin, Dev and Prod accounts
- Terraform user in Admin account (can assume roles)
- Dev and Prod Terraform roles for Admin Terraform user
- Terraform Cloud
  - Create dev and prod workspaces
  - Attach git repo to Run in the Cloud
  - Disable remote execution to run locally
## Local
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- Set terraform cloud organisation in `main.tf`
- `terraform init`
- [Terraform Cloud Login](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-login)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [AWS CLI Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html) (or pass keys to Terraform as ENV variables)

# Run locally
- `terraform workspace select dev`
- Fill in `dev.tfvars`
- `terraform apply -var-file=dev.tfvars`

# Run in Terraform Cloud
- Add required variables
- Run (or add VCS trigger to run automatically)

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
- ~~CI (GitHub Actions or Terraform Cloud)~~ Done in Terraform Cloud (for prod environemnt), [see for example](https://github.com/yakimant/terraform_static_website_deployment/commits/main)
- Custom DNS CNAME for CloudFront
- Separate, non-default VPCs for Dev and Prod EC2
