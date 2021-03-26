resource "aws_lambda_function" "rekognition_requester" {
  function_name = var.lambda_rekognition_requester_function_name
  role = aws_iam_role.rekognitionlambda.arn
  runtime = "python3.8"
  handler = "main.lambda_handler"
  filename      = "${path.root}/.archive_files/lambda_requester.zip"
  timeout       = 60
  memory_size   = 256
  source_code_hash = data.archive_file.lambda_requester.output_base64sha256

  environment {
    variables = {
      PublishRoleArn = aws_iam_role.rekognitionsns.arn
      SNSTopicArn = aws_sns_topic.rekognition.arn
    }
  }

  depends_on = [
    aws_iam_role.rekognitionlambda,
    data.archive_file.lambda_requester
  ]
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rekognition_requester.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.rekognition_trigger.arn
}


data "archive_file" "lambda_requester" {
  type        = "zip"
  output_path = "${path.root}/.archive_files/lambda_requester.zip"

  # fingerprinter
  source {
    filename = "main.py"
    content  = <<-CODE
from __future__ import print_function

import boto3
import json
import os

print('Loading function')

rekognition = boto3.client('rekognition')

publishrolearn = os.environ['PublishRoleArn']
snstopicarn = os.environ['SNSTopicArn']

# --------------- Main handler ------------------


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    try:
        # Calls rekognition DetectFaces API to detect faces in S3 object
        response = rekognition.start_face_detection(
            Video={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            },
            NotificationChannel={
                'SNSTopicArn': snstopicarn,
                'RoleArn': publishrolearn
            }
        )
        
        print(response)
        print('Published to ' + snstopicarn + ' with permission ' + publishrolearn)

        return response
    except Exception as e:
        print(e)
        print("Error processing object {} from bucket {}. ".format(key, bucket) +
              "Make sure your object and bucket exist and your bucket is in the same region as this function.")
        raise e
CODE
  }
}

resource "aws_lambda_function" "rekognition_responder" {
  function_name = var.lambda_rekognition_responder_function_name
  role = aws_iam_role.rekognitionlambda.arn
  runtime = "python3.8"
  handler = "main.lambda_handler"
  filename      = "${path.root}/.archive_files/lambda_responder.zip"
  timeout       = 60
  memory_size   = 256
  source_code_hash = data.archive_file.lambda_responder.output_base64sha256
  # ... other configuration ...
  depends_on = [
    aws_iam_role.rekognitionlambda,
    data.archive_file.lambda_responder
  ]

  environment {
    variables = {
      OutputBucket = aws_s3_bucket.rekognition_output.id
    }
  }
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rekognition_responder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.rekognition.arn
}

data "archive_file" "lambda_responder" {
  type        = "zip"
  output_path = "${path.root}/.archive_files/lambda_responder.zip"

  # fingerprinter
  source {
    filename = "main.py"
    content  = <<-CODE
from __future__ import print_function


import boto3
import json
import os

rekognition = boto3.client('rekognition')
s3 = boto3.client('s3')
outputbucket = os.environ['OutputBucket']

# --------------- Main handler ------------------


def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))
    message = event['Records'][0]['Sns']['Message']
    print('Message: '+ message)
    jobId = (json.loads(message))['JobId']
    print('JobId: ' + jobId )

    response = rekognition.get_face_detection(
        JobId=jobId
        #,MaxResults=123
        #,NextToken='string'
    )
    
    s3.put_object(Body=json.dumps(response), Bucket=outputbucket, Key='test.json')
    print("RESPONSE: " + json.dumps(response))
CODE
  }
}