# Package the Lambda function code into zip
data "archive_file" "code_file" {
  type        = "zip"
  source_file = "${path.module}/../../Backend/lambda.py"
  output_path = "${path.module}/../../Backend/lambda.zip"
}

# Lambda function
resource "aws_lambda_function" "main_lambda_function" {
  filename         = data.archive_file.code_file.output_path
  function_name    = var.lambda_name
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.code_file.output_base64sha256
  runtime          = "python3.12"


  environment {
    variables = {
      lambda_name  = var.lambda_name
      dynamo_table = var.table_name
    }
  }

  depends_on = [aws_s3_bucket.static_code_bucket, aws_dynamodb_table.views_table]
}

# Exposing the lambda function using a url
resource "aws_lambda_function_url" "lambda_url" {
  function_name      = aws_lambda_function.main_lambda_function.function_name
  qualifier          = "$LATEST"
  authorization_type = "NONE"

  # allow this url to only be accessed from cloudfront 
  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
  depends_on = [aws_lambda_function.main_lambda_function]
}

# Allows cloudfront or other aws resources to access the lambda url 
resource "aws_lambda_permission" "allow_public_url_access" {
  statement_id           = "AllowPublicURLInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.main_lambda_function.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
