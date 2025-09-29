# DynamoDB Table
resource "aws_dynamodb_table" "this" {
  provider     = aws.localstack
  name         = "items_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# IAM Role for Lambda
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::000000000000:role/lambda-role"]
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
}

# Lambda Function
data "archive_file" "this" {
  type        = "zip"
  source_file = "${path.module}/../app/app.py"
  output_path = "${path.module}/../app/app.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = "lambda_handler"
  role             = aws_iam_role.this.arn
  source_code_hash = data.archive_file.this.output_base64sha256
  handler          = "app.lambda_handler"
  runtime          = "python3.9"

}

# REST API Gateway (v1)
resource "aws_api_gateway_rest_api" "this" {
  name = "items_api"
}

# /items
resource "aws_api_gateway_resource" "items" {
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "items"
}

# GET /items
resource "aws_api_gateway_method" "get_items" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.items.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "get_items" {
  http_method             = aws_api_gateway_method.get_items.http_method
  resource_id             = aws_api_gateway_resource.items.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.this.invoke_arn
}

# PUT /items
resource "aws_api_gateway_method" "put_items" {
  authorization = "NONE"
  http_method   = "PUT"
  resource_id   = aws_api_gateway_resource.items.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "put_items" {
  http_method             = aws_api_gateway_method.put_items.http_method
  resource_id             = aws_api_gateway_resource.items.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.this.invoke_arn
}

# /items/{id}
resource "aws_api_gateway_resource" "items_id" {
  parent_id   = aws_api_gateway_resource.items.id
  rest_api_id = aws_api_gateway_rest_api.this.id
  path_part   = "items_id"
}

# GET /items/{id}
resource "aws_api_gateway_method" "get_items_id" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.items_id.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "items_id" {
  http_method             = aws_api_gateway_method.get_items_id.http_method
  resource_id             = aws_api_gateway_resource.items_id.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.this.invoke_arn
}

# DELETE /items/{id}
resource "aws_api_gateway_method" "delete_items_id" {
  authorization = "NONE"
  http_method   = "DELETE"
  resource_id   = aws_api_gateway_resource.items_id.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_integration" "delete_items_id" {
  http_method             = aws_api_gateway_method.delete_items_id.http_method
  resource_id             = aws_api_gateway_resource.items_id.id
  rest_api_id             = aws_api_gateway_rest_api.this.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  depends_on = [ aws_api_gateway_integration.get_items,
                 aws_api_gateway_integration.put_items,
                 aws_api_gateway_integration.items_id,
                 aws_api_gateway_integration.delete_items_id,
                 aws_api_gateway_method.delete_items_id,
                 aws_api_gateway_method.get_items,
                 aws_api_gateway_method.get_items_id,
                 aws_api_gateway_method.put_items ]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.get_items.id,
      aws_api_gateway_method.put_items.id,
      aws_api_gateway_method.get_items_id.id,
      aws_api_gateway_method.delete_items_id.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "this"
}
