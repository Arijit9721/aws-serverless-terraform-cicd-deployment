output "bucket_endpoint" {
  value = aws_s3_bucket.static_code_bucket.bucket_regional_domain_name
}

# the url of the cloudfront
output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

# Add this id to github secrets
output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}