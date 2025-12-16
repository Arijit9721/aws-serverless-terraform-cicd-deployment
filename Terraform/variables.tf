variable "region" {
  type = string
  default = "us-east-1"
}
variable "bucket-name" {
  type = string
  default = "arijit21-portfolio-website-hosting-bucket"
}
variable "cloudfront-name" {
  type = string
  default = "portfolio-website-cloudfront"
}
variable "table_name" {
  type = string
  default = "portfolio-website-dynamodb-table"
}
variable "hash_key" {
  type = string
  default = "websites"
}
variable "second_key" {
  type = string
  default = "views"
}
variable "lambda_name" {
  type = string
  default = "portfolio-website-lambda"
}