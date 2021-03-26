resource "aws_athena_database" "rekognition" {
  name   = "database_rekognition"
  bucket = aws_s3_bucket.rekognition_athena_results.bucket
}