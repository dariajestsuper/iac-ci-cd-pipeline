output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "resource_id" {
  value = aws_api_gateway_resource.items_id.id
}

output "path_get_put" {
  value = aws_api_gateway_resource.items.path
}

output "path_with_id" {
  value = aws_api_gateway_resource.items_id.path
}