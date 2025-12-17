# role for the lambda function
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Policy to provide the needed permissions
resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_name}-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # The essential cloudwatch permissions
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      # The s3 bucket and object permissions
      {
        Action = [
          "s3:GetObjects",
          "s3:ListBucket",
        ]
        Effect = "Allow"
        Resource = [aws_s3_bucket.static_code_bucket.arn, # The bucket that lambda can access
          "${aws_s3_bucket.static_code_bucket.arn}/*"     # allows the objects of the bucket to be accessed
        ]
      },
      # The dynamodb table permissions
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.views_table.arn
      },
    ]
  })
}

# Attaching the policy to the role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}