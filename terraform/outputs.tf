# output "rest_api_id" {
#   value = aws_api_gateway_rest_api.this.id
# }

output "lambda_function_url" {
  value = aws_lambda_function_url.this.function_url
}

