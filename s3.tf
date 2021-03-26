resource "aws_s3_bucket" "rekognition_trigger" {
  bucket_prefix = "rekognition-trigger-"
  acl    = "private"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.rekognition_trigger.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.rekognition_requester.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_s3_bucket" "rekognition_output" {
  bucket_prefix = "rekognition-output-"
  acl    = "private"
}

resource "aws_s3_bucket" "rekognition_athena_results" {
  bucket_prefix = "rekognition-athena-results-"
}