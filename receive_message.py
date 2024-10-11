import boto3
import json
import subprocess
import time

# Get the queue URL from Terraform output
result = subprocess.run(['terraform', 'output', '-raw', 'queue_url'], capture_output=True, text=True)
queue_url = result.stdout.strip()

# Create SQS client
sqs = boto3.client('sqs')

print(f"Listening for messages on queue: {queue_url}")
print("Press CTRL+C to exit")

try:
    while True:
        # Receive message from SQS queue
        response = sqs.receive_message(
            QueueUrl=queue_url,
            AttributeNames=['All'],
            MaxNumberOfMessages=1,
            MessageAttributeNames=['All'],
            VisibilityTimeout=0,
            WaitTimeSeconds=20
        )

        # Check if any messages were received
        messages = response.get('Messages', [])
        
        for message in messages:
            print("\nReceived message:")
            print(f"Message ID: {message['MessageId']}")
            print(f"Message Body: {message['Body']}")
            
            # Parse the JSON in the message body
            body = json.loads(message['Body'])
            print(f"Parsed Message Content: {body['content']}")
            print(f"Timestamp: {body['timestamp']}")
            
            # Delete the message from the queue
            sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=message['ReceiptHandle']
            )
            print("Message deleted from the queue")
        
        if not messages:
            print("No messages received. Waiting...")

except KeyboardInterrupt:
    print("\nStopping message receiver")