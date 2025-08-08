resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "aws_s3_bucket" "hello" {
  bucket = "hello-tf-${random_string.suffix.result}"
}

