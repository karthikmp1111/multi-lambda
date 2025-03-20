# locals {
#   lambda_files = { for name in var.lambda_names : name => filebase64sha256("${path.module}/../lambda-functions/${name}/package.zip") }
# }

# resource "aws_lambda_function" "lambda" {
#   for_each      = local.lambda_files
#   function_name = each.key
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   filename         = "${path.module}/../lambda-functions/${each.key}/package.zip"
#   source_code_hash = each.value
#   publish = true

#   environment {
#     variables = {
#       ENV = "dev"
#     }
#   }
# }

# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_execution_role_test"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })
# }





terraform {
  backend "s3" {
    bucket         = "bg-kar-terraform-state"
    key            = "lambda/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
  }
}

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
  publish          = true  # Creates a new version only when needed

  environment {
    variables = {
      ENV = "dev"
    }
  }

  lifecycle {
    ignore_changes = [source_code_hash]  # Prevents unnecessary redeployments
  }
}

# Alias to always point to the latest stable version
resource "aws_lambda_alias" "lambda_alias" {
  for_each         = aws_lambda_function.lambda
  name             = "latest"
  function_name    = each.value.function_name
  function_version = each.value.version
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  # Least Privilege Policy
  inline_policy {
    name = "lambda_basic_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}
