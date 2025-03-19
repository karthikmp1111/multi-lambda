output "lambda1_arn" {
  value = aws_lambda_function.lambda1.arn
}

output "lambda2_arn" {
  value = aws_lambda_function.lambda2.arn
}

output "lambda1_version" {
  value = aws_lambda_version.lambda1_version.version
}

output "lambda2_version" {
  value = aws_lambda_version.lambda2_version.version
}
