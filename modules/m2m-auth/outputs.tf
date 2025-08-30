output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "cognito_user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.arn
}

output "cognito_user_pool_domain" {
  description = "The domain for the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.this.domain
}

output "apigatewayv2_api_id" {
  description = "The ID of the API Gateway V2 API"
  value       = aws_apigatewayv2_api.this.id
}

output "apigatewayv2_api_endpoint" {
  description = "The endpoint of the API Gateway V2 API"
  value       = aws_apigatewayv2_api.this.api_endpoint
}