# Configure the AWS provider
provider "aws" {
  region = "us-west-2"  # Change this to your preferred region
}

# Create the SQS FIFO queue
resource "aws_sqs_queue" "demo_queue" {
  name                        = "demo-q.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  # Set reasonable defaults for message retention and visibility timeout
  message_retention_seconds = 86400  # 1 day
  visibility_timeout_seconds = 30

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Add tags for better resource management
  tags = {
    Name        = "demo-q"
    Environment = "Development"
    Project     = "POC-SQS"
  }
}

# Output the queue URL and ARN
output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.demo_queue.url
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.demo_queue.arn
}