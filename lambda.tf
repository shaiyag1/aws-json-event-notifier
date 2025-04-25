resource "aws_lambda_function" "json_event_handler" {
  function_name = "json_event_handler"
  runtime       = "python3.12"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn

  filename         = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")

  timeout = 10

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.file_upload_topic.arn
    }
  }
}
