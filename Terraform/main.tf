module "main" {
  source = "./modules"

  region          = var.region
  bucket-name     = var.bucket-name
  cloudfront-name = var.cloudfront-name
  table_name      = var.table_name
  hash_key        = var.hash_key
  lambda_name     = var.lambda_name
}