# Create a random suffix for the IAM role
resource "random_id" "role_suffix" {
  byte_length = 8
}

# Create IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "consumer_two_lambda_role_${random_id.role_suffix.hex}"

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

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    var.common_tags,
    {
      Name = "demo-lambda-role-consumer-two"
    }
  )
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

# Create S3 bucket for consumer_two
resource "aws_s3_bucket" "consumer_two_bucket" {
  bucket = "sqs-consumer-two-${random_id.bucket_suffix.hex}"

  tags = merge(
    var.common_tags,
    {
      Name = "sqs-consumer-two-bucket"
    }
  )
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Create Lambda function
resource "aws_lambda_function" "process_sqs_message" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "process_sqs_message_consumer_two"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.consumer_two_bucket.id
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name = "process-sqs-message-consumer-two"
    }
  )
}

# The SQS trigger for Lambda has been removed