resource "aws_dynamodb_table" "trade_logs" {
  name           = "trade_logs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "trade_id"

  attribute {
    name = "trade_id"
    type = "S"
  }

  tags = {
    Name = "trade_logs"
  }
}
