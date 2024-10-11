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

# Create S3 bucket for storing messages
resource "aws_s3_bucket" "message_store" {
  bucket = "demo-sqs-message-store-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "demo_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.lambda_role.name
}

# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Create Lambda function
resource "aws_lambda_function" "process_sqs_message" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "process_sqs_message"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.message_store.id
    }
  }
}

# Create SQS trigger for Lambda
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.demo_queue.arn
  function_name    = aws_lambda_function.process_sqs_message.arn
  batch_size       = 1
}

# Outputs
output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.message_store.id
}

# Existing outputs...