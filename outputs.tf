output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.demo_queue.url
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.demo_queue.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.message_store.id
}

output "mailhog_public_ip" {
  description = "The public IP address of the Mailhog instance"
  value       = module.mailhog.public_ip
}

output "mailhog_smtp_endpoint" {
  description = "The SMTP endpoint for Mailhog"
  value       = module.mailhog.smtp_endpoint
}

output "mailhog_web_ui_url" {
  description = "The URL for accessing Mailhog Web UI"
  value       = module.mailhog.web_ui_url
}

# Commented out consumer_one and consumer_two outputs
# output "consumer_one_lambda_function_name" {
#   description = "The name of the consumer_one Lambda function"
#   value       = module.consumer_one.lambda_function_name
# }
#
# output "consumer_two_lambda_function_name" {
#   description = "The name of the consumer_two Lambda function"
#   value       = module.consumer_two.lambda_function_name
# }