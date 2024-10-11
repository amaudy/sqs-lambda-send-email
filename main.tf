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

# Create S3 bucket for storing messages
resource "aws_s3_bucket" "message_store" {
  bucket = "demo-sqs-message-store-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Call the consumer_one module
module "consumer_one" {
  source = "./modules/consumer_one"

  sqs_queue_arn = aws_sqs_queue.demo_queue.arn
  s3_bucket_id  = aws_s3_bucket.message_store.id
}

# Call the consumer_two module
module "consumer_two" {
  source = "./modules/consumer_two"

  sqs_queue_arn = aws_sqs_queue.demo_queue.arn
}