# SQS and Lambda Project

This project sets up an AWS SQS queue, an S3 bucket, and a Lambda function to process messages.

## Structure

## Security Configuration

To enhance security, we'll restrict access to the Mailhog instance to only allow connections from your current public IP address. This configuration is implemented using Terraform and automatically detects your IP address.

### Security Group Rules

The security group rules are defined in the `security.tf` file. The configuration automatically fetches your current public IP address using an external data source.

## Important Notes

- Ensure that you have the necessary AWS credentials configured for Terraform to make changes to your AWS account.
- The security group rule will be updated with your current IP address each time you run `terraform apply`.
- If you're behind a NAT or your IP changes frequently, you may need to reapply the Terraform configuration to update the security group rule.
- Regularly review your security group rules to maintain a strong security posture.

## Terraform Usage

1. Initialize Terraform: `terraform init`
2. Plan the changes: `terraform plan`
3. Apply the changes: `terraform apply`

The configuration will automatically use your current public IP address when applying the security group rule.
