resource "aws_lambda_function" "json_event_handler" {
  function_name = var.lambda_function_name

  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role = coalesce(
  try(aws_iam_role.lambda_exec[0].arn, null),
  data.aws_iam_role.lambda_exec.arn
)


  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")

  timeout = 10

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.file_upload_topic.arn
    }
  }
}
