
# The s3 bucket to host the static frontend 
resource "aws_s3_bucket" "static_code_bucket" {
  bucket = var.bucket-name

  tags = {
    Name = "static_code_bucket"
  }
}

# Enabling versioning on the bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.static_code_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# lifecycle rule to ensure that non-current buckets are deleted accordingly
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.static_code_bucket.id

  rule {
    id     = "expire-noncurrent-objects"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.versioning]
}

# Configure the Public Access Block to allow public access
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.static_code_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Bucket policy to allow public access to s3
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.static_code_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Resource = "${aws_s3_bucket.static_code_bucket.arn}/*" # Grants access to all objects in the bucket
        condition = {
          stringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn # Grants access to only this cloudfront
          }
        }
      }
    ]
  })
}

