variable "region" {
  type = string
  default = "us-east-1"
}
variable "bucket-name" {}
variable "cloudfront-name" {}
variable "table_name" {}
variable "hash_key" {
  type = string
  default = "websites"
}
variable "second_key" {
  type = string
  default = "views"
}
variable "lambda_name" {}