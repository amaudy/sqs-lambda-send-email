# Configure the AWS provider
provider "aws" {
  region = "us-west-2" # Change this to your preferred region
}

locals {
  common_tags = {
    Environment = "Development"
    Project     = "POC-SQS"
    ManagedBy   = "Terraform"
  }
}

# Create the SQS FIFO queue
resource "aws_sqs_queue" "demo_queue" {
  name                        = "demo-q.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"

  # Set reasonable defaults for message retention and visibility timeout
  message_retention_seconds  = 86400 # 1 day
  visibility_timeout_seconds = 30

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Add tags for better resource management
  tags = merge(
    local.common_tags,
    {
      Name = "demo-q"
    }
  )
}

# Create S3 bucket for storing messages
resource "aws_s3_bucket" "message_store" {
  bucket = "demo-sqs-message-store-${random_id.bucket_suffix.hex}"

  # Add tags for better resource management
  tags = merge(
    local.common_tags,
    {
      Name = "demo-sqs-message-store"
    }
  )
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Call the mailhog module
module "mailhog" {
  source = "./modules/mailhog"

  common_tags = local.common_tags
}

# Commented out consumer_one module
# module "consumer_one" {
#   source = "./modules/consumer_one"
#
#   sqs_queue_arn = aws_sqs_queue.demo_queue.arn
#   s3_bucket_id  = aws_s3_bucket.message_store.id
#   common_tags   = local.common_tags
# }

# Commented out consumer_two module
# module "consumer_two" {
#   source = "./modules/consumer_two"
#
#   sqs_queue_arn = aws_sqs_queue.demo_queue.arn
#   common_tags   = local.common_tags
# }