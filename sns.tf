resource "aws_sns_topic" "rekognition" {
  name_prefix = "rekognitiontopic-"
}

resource "aws_sns_topic_subscription" "rekognition_responder" {
  topic_arn = aws_sns_topic.rekognition.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.rekognition_responder.arn
}