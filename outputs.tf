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

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = module.consumer_one.lambda_function_name
}

output "consumer_two_lambda_function_name" {
  description = "The name of the consumer_two Lambda function"
  value       = module.consumer_two.lambda_function_name
}

output "consumer_two_s3_bucket_name" {
  description = "The name of the S3 bucket for consumer_two"
  value       = module.consumer_two.s3_bucket_name
}