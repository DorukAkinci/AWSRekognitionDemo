variable "provider_aws_region" {
      description = "Provider AWS Region"
      default="eu-central-1"
    }
variable "provider_aws_profile" { 
     description = "Provider AWS Profile" 
     default="default"
    }

variable "lambda_rekognition_requester_function_name" {
  default = "rekognition_requester"
}

variable "lambda_rekognition_responder_function_name" {
  default = "rekognition_responder"
}
