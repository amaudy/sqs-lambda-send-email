variable "sqs_queue_arn" {
  description = "The ARN of the SQS queue"
  type        = string
}

variable "mailhog_smtp_endpoint" {
  description = "The SMTP endpoint for Mailhog"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}