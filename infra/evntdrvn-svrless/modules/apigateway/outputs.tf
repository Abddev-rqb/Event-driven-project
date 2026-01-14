output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.region}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
}

output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}
