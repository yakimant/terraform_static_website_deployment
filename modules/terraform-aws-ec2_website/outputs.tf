output "ec2_public_ip" {
  value = aws_instance.ec2_website.public_ip
}

output "domain_name" {
  value = aws_cloudfront_distribution.ec2_website_cloudfront.domain_name
}