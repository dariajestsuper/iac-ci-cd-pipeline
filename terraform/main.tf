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

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type =  "Federated"
      identifiers = ["arn:aws:iam::000000000000:role/lambda-role"]
    }
  }
}

resource "aws_iam_role" "this" {
  assume_role_policy = data.aws_iam_policy_document.this.json
}

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

resource "aws_lambda_function_url" "this" {
  function_name = aws_lambda_function.this.function_name
  authorization_type = "NONE"
}

# resource "aws_api_gateway_rest_api" "this" {
#   name = "items_api"
# }

# resource "aws_api_gateway_resource" "this" {
#   parent_id   = aws_api_gateway_rest_api.this.root_resource_id
#   path_part   = "items"
#   rest_api_id = aws_api_gateway_rest_api.this.id
# }

# resource "aws_api_gateway_method" "this" {
#   authorization = "NONE"
#   http_method   = "GET"
#   resource_id   = aws_api_gateway_resource.this.id
#   rest_api_id   = aws_api_gateway_rest_api.this.id
# }

# resource "aws_api_gateway_integration" "this" {
#   http_method = aws_api_gateway_method.this.http_method
#   resource_id = aws_api_gateway_resource.this.id
#   rest_api_id = aws_api_gateway_rest_api.this.id
#   type        = "MOCK"
# }

# resource "aws_api_gateway_deployment" "this" {
#   rest_api_id = aws_api_gateway_rest_api.this.id

#   triggers = {
#     # NOTE: The configuration below will satisfy ordering considerations,
#     #       but not pick up all future REST API changes. More advanced patterns
#     #       are possible, such as using the filesha1() function against the
#     #       Terraform configuration file(s) or removing the .id references to
#     #       calculate a hash against whole resources. Be aware that using whole
#     #       resources will show a difference after the initial implementation.
#     #       It will stabilize to only change when resources change afterwards.
#     redeployment = sha1(jsonencode([
#       aws_api_gateway_resource.this.id,
#       aws_api_gateway_method.this.id,
#       aws_api_gateway_integration.this.id,
#     ]))
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "this" {
#   deployment_id = aws_api_gateway_deployment.this.id
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   stage_name    = "this"
# }