variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}

variable "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}