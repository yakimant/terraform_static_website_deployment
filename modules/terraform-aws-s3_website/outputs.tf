output "domain_name" {
  value = aws_cloudfront_distribution.s3_website_cloudfront.domain_name
}

output "bucket_id" {
  value = module.s3_bucket.s3_bucket_id
}