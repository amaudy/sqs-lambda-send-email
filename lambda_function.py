import json
import boto3
import os
import hashlib
from datetime import datetime

s3 = boto3.client('s3')
S3_BUCKET = os.environ['S3_BUCKET']

def lambda_handler(event, context):
    for record in event['Records']:
        # Parse the message body
        message_body = json.loads(record['body'])
        
        # Generate filename using hash of timestamp
        timestamp = message_body.get('timestamp', str(datetime.now().timestamp()))
        filename = hashlib.md5(str(timestamp).encode()).hexdigest() + '.json'
        
        # Store message in S3
        s3.put_object(
            Bucket=S3_BUCKET,
            Key=filename,
            Body=json.dumps(message_body),
            ContentType='application/json'
        )
        
        print(f"Message stored in S3: s3://{S3_BUCKET}/{filename}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Messages processed successfully')
    }