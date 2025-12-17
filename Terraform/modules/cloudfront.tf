# Allows cloudfront to safely connect to private s3 buckets
resource "aws_cloudfront_origin_access_control" "s3-oac" {
  name                              = "${var.cloudfront-name}-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# The cloudfront resource 
resource "aws_cloudfront_distribution" "s3_distribution" {

  # origin of the s3 bucket for static website hosting
  origin {
    domain_name              = aws_s3_bucket.static_code_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3-oac.id
    origin_id                = "S3-${var.bucket-name}"
  }

  # origin of the lambda function for api calls
  origin {
    domain_name = replace(aws_lambda_function_url.lambda_url.function_url, "https://", "")
    origin_id   = "Lambda-API"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  price_class         = "PriceClass_200"
  default_root_object = "index.html"

  # When the client visits for the first time, call the lambda and cache the website
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.bucket-name}"
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Premade policy for optimized caching 
  }

  # when the website is served from cloudfront cache, call the lambda but don't cache the website
  ordered_cache_behavior {
    path_pattern             = "/api/*"
    target_origin_id         = "Lambda-API"
    cache_policy_id          = "4135d2f9-1017-47ca-8189-4839840eb3ad" # Premade policy to stop caching
    origin_request_policy_id = "b689b0a8-53d0-40a8-baf7-d57312e4e027" # Premade policy for header/cookies handling
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    viewer_protocol_policy   = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_lambda_function_url.lambda_url]
}
