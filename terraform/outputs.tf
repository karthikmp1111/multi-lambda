output "lambda_arns" {
  value = { for k, v in aws_lambda_function.lambda : k => v.arn }
}
