provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "upload_bucket" {
  bucket        = "shai-json-event-bucket"
  force_destroy = true
}
