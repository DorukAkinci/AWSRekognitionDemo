resource "aws_iam_role" "rekognitionlambda" {
  name_prefix = "RekognitionLambdaRole-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
        name = "CloudwatchLogs"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action   = ["logs:CreateLogGroup"]
                    Effect   = "Allow"
                    Resource = "*"
                },
                {
                    Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
                    Effect   = "Allow"
                    Resource = [
                            "arn:aws:logs:${var.provider_aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_rekognition_requester_function_name}:*",
                            "arn:aws:logs:${var.provider_aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_rekognition_responder_function_name}:*"
                        ]
                },
            ]
        })
    }

    inline_policy {
        name = "IAM-PassRole"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action   = ["iam:PassRole"]
                    Effect   = "Allow"
                    Resource = "*"
                }
            ]
        })
    }

    inline_policy {
        name = "Rekognition"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action   = ["rekognition:StartFaceDetection", "rekognition:GetFaceDetection"]
                    Effect   = "Allow"
                    Resource = "*"
                }
            ]
        })
    }

    inline_policy {
        name = "S3"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action   = ["s3:List*", "s3:PutObject", "s3:GetObject"]
                    Effect   = "Allow"
                    Resource = "*"
                }
            ]
        })
    }
}


resource "aws_iam_role" "rekognitionsns" {
  name_prefix = "RekognitionSnsRole-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rekognition.amazonaws.com"
        }
      },
    ]
  })

    inline_policy {
        name = "SNS-Publish"
        policy = jsonencode({
            Version = "2012-10-17"
            Statement = [
                {
                    Action   = ["sns:Publish"]
                    Effect   = "Allow"
                    Resource = "*"
                }
            ]
        })
    }
    
}