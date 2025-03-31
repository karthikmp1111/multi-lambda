# locals {
#   lambda_files = { for name in var.lambda_names : name => filebase64sha256("${path.module}/../lambda-functions/${name}/package.zip") }
# }

# locals {
#   lambda_files = { for name in var.lambda_names : name => filebase64sha256("s3://bg-kar-terraform-state/lambda-packages/${name}/package.zip") }
# }

# resource "aws_lambda_function" "lambda" {
#   for_each      = local.lambda_files
#   function_name = each.key
#   role          = aws_iam_role.lambda_role.arn
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   filename         = "${path.module}/../lambda-functions/${each.key}/package.zip"
#   source_code_hash = each.value
#   publish          = true

#   environment {
#     variables = {
#       ENV = "dev"
#     }
#   }

#   lifecycle {
#     ignore_changes = [environment, publish]  # Ignores changes in environment variables & publish flag
#   }
# }

# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = { Service = "lambda.amazonaws.com" }
#     }]
#   })

#   lifecycle {
#     ignore_changes = [name]  # Prevents unnecessary IAM role recreation
#   }
# }


# locals {
#   lambda_files = {
#     for name in var.lambda_names : name => "s3://bg-kar-terraform-state/lambda-packages/${name}/package.zip"
#   }
# }
locals {
  lambda_files = { for name in var.lambda_names : name => filebase64sha256("s3://$S3_BUCKET/lambda-packages/${name}/package.zip") }
}
resource "aws_lambda_function" "lambda" {
  for_each      = local.lambda_files
  function_name = each.key
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  # Directly specify the S3 bucket and key for the Lambda function package
  s3_bucket = "bg-kar-terraform-state"
  s3_key    = "lambda-packages/${each.key}/package.zip"

  # If you want to hash the S3 package to track changes
  source_code_hash = each.value

  publish          = true

  environment {
    variables = {
      ENV = "dev"
      NEW_VARIABLE = "bg_lambda_test"
    }
  }

  lifecycle {
    ignore_changes = [environment, publish]  # Ignores changes in environment variables & publish flag
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "bg_lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  lifecycle {
    ignore_changes = [name]  # Prevents unnecessary IAM role recreation
  }
}
