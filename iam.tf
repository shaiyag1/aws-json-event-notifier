# 1. Look for an existing role
data "aws_iam_role" "lambda_exec" {
  name = "lambda_json_event_role"
  # If it doesn't exist, the plan will fail unless created below
}

# 2. Optionally create it if needed (controlled outside Terraform plan)
resource "aws_iam_role" "lambda_exec" {
  count = data.aws_iam_role.lambda_exec.id != "" ? 0 : 1

  name = "lambda_json_event_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# 3. Attach the policy to the right role (either existing or newly created)
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_json_event_policy"

	role = coalesce(
	  try(aws_iam_role.lambda_exec[0].name, null),
	  data.aws_iam_role.lambda_exec.name
	)


  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = "arn:aws:s3:::shai-json-event-bucket/*"
      },
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "arn:aws:sns:us-east-1:360300555134:file-upload-notification"
      }
    ]
  })
}
