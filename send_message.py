import boto3
import json
import subprocess
import time
import csv

# Get the queue URL from Terraform output
result = subprocess.run(['terraform', 'output', '-raw', 'queue_url'], capture_output=True, text=True)
queue_url = result.stdout.strip()

# Create SQS client
sqs = boto3.client('sqs')

# Function to send a single message
def send_message(customer):
    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(customer),
        MessageGroupId='group1',
        MessageDeduplicationId=str(int(time.time() * 1000))  # Use milliseconds for deduplication
    )

    print(f"Message sent for {customer['FirstName']} {customer['LastName']}. Message ID: {response['MessageId']}")

# Read customer data from CSV and send messages
with open('customer_data.csv', 'r') as csvfile:
    reader = csv.DictReader(csvfile)
    for row in reader:
        send_message(row)
        time.sleep(1)  # Wait for 1 second between messages

print("All messages sent.")