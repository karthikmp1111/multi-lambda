locals {
  lambda_files = { for name in var.lambda_names : name => filebase64sha256("${path.module}/../lambda-functions/${name}/package.zip") }
}

resource "aws_lambda_function" "lambda" {
  for_each      = local.lambda_files
  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  filename         = "${path.module}/../lambda-functions/${each.key}/package.zip"
  source_code_hash = each.value
  publish = true

  environment {
    variables = {
      ENV = "dev"
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role_test"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}