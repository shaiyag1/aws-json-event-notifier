provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "upload_bucket" {
    bucket = var.upload_bucket_name
	force_destroy = true
}
