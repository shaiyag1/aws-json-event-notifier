resource "aws_sns_topic" "file_upload_topic" {
  name = "file-upload-notification"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.file_upload_topic.arn
  protocol  = "email"
  endpoint  = "shaip.yag@gmail.com"  # 🔁 Replace with your real email
}
