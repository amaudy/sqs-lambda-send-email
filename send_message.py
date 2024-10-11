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

# Function to send a single message
def send_message(message_number):
    message = {
        "id": str(uuid.uuid4()),
        "content": f"Hello, SQS! Message {message_number}",
        "timestamp": time.time()
    }

    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(message),
        MessageGroupId='group1',
        MessageDeduplicationId=str(int(time.time() * 1000))  # Use milliseconds for deduplication
    )

    print(f"Message {message_number} sent. Message ID: {response['MessageId']}")

# Send 100 messages with 1 second delay between each
for i in range(1, 101):
    send_message(i)
    time.sleep(1)  # Wait for 1 second

print("All messages sent.")