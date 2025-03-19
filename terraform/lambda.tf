resource "aws_lambda_function" "lambda1" {
  function_name    = "lambda1"
  handler         = "main.lambda_handler"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  filename        = "../lambda1.zip"
  source_code_hash = filebase64sha256("../lambda1.zip")
}

resource "aws_lambda_function" "lambda2" {
  function_name    = "lambda2"
  handler         = "main.lambda_handler"
  runtime         = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  filename        = "../lambda2.zip"
  source_code_hash = filebase64sha256("../lambda2.zip")
}

# Lambda Versioning
resource "aws_lambda_version" "lambda1_version" {
  function_name = aws_lambda_function.lambda1.function_name
}

resource "aws_lambda_version" "lambda2_version" {
  function_name = aws_lambda_function.lambda2.function_name
}
