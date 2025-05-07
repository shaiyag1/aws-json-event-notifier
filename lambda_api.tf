resource "aws_lambda_function" "api_handler" {
  function_name = "api_submit_trade"
  runtime       = "python3.12"
  handler       = "api_lambda_function.lambda_handler"  # file.function

  filename         = "${path.module}/lambda/api_lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/api_lambda_function.zip")

  timeout = 5
  role = coalesce(try(aws_iam_role.lambda_exec[0].arn, null), data.aws_iam_role.lambda_exec.arn)


}


resource "aws_apigatewayv2_api" "http_api" {
  name          = "trade_api"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                = aws_apigatewayv2_api.http_api.id
  integration_type      = "AWS_PROXY"
  integration_uri       = aws_lambda_function.api_handler.invoke_arn
  integration_method    = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "post_trade" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /submit-trade"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "get_trades" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /trades"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}
