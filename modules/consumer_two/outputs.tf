output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.process_sqs_message.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.process_sqs_message.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for consumer_two"
  value       = aws_s3_bucket.consumer_two_bucket.id
}