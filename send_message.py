import boto3
import json
import subprocess
import time
import uuid

# Get the queue URL from Terraform output
result = subprocess.run(['terraform', 'output', '-raw', 'queue_url'], capture_output=True, text=True)
queue_url = result.stdout.strip()

# Create SQS client
sqs = boto3.client('sqs')

# Message to send
message = {
    "id": str(uuid.uuid4()),
    "content": "Hello, SQS!",
    "timestamp": time.time()
}

# Send message to SQS queue
response = sqs.send_message(
    QueueUrl=queue_url,
    MessageBody=json.dumps(message),
    MessageGroupId='group1',
    MessageDeduplicationId=str(int(time.time()))
)

print(f"Message sent. Message ID: {response['MessageId']}")