output "s3_bucket_website_url" {
  value = "https://${module.s3_website.domain_name}"
}

output "ec2_website_public_ip" {
  value = module.ec2_website.ec2_public_ip
}

output "ec2_website_url" {
  value = "https://${module.ec2_website.domain_name}"
}