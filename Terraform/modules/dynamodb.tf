# table to store the views count
resource "aws_dynamodb_table" "views_table" {
  name         = var.table_name
  hash_key     = var.hash_key
  billing_mode = "PAY_PER_REQUEST"
  region       = var.region

  attribute {
    name = var.hash_key
    type = "S"
  }

  attribute {
    name = var.second_key
    type = "N"
  }

  # this script runs after table creation to add values to the table
  provisioner "local-exec" {
    command = "python3 ${path.cwd}/insert_data.py"

    environment = {
      table_name = var.table_name
      hash_key   = var.hash_key
      second_key = var.second_key
    }

  }
}