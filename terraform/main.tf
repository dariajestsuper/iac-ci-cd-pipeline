resource "aws_dynamodb_table" "main" {
  provider     = aws.localstack
  name         = "items_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}