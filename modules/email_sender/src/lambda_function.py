import json
import boto3
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def lambda_handler(event, context):
    mailhog_smtp_endpoint = os.environ['MAILHOG_SMTP_ENDPOINT']
    smtp_host, smtp_port = mailhog_smtp_endpoint.split(':')

    for record in event['Records']:
        message = json.loads(record['body'])
        
        # Create the email
        msg = MIMEMultipart()
        msg['From'] = "noreply@example.com"
        msg['To'] = message['Email']
        msg['Subject'] = f"Hello {message['FirstName']}!"
        
        body = f"Dear {message['FirstName']} {message['LastName']},\n\nThis is a test email sent from AWS Lambda using Mailhog."
        msg.attach(MIMEText(body, 'plain'))

        # Send the email
        with smtplib.SMTP(smtp_host, int(smtp_port)) as server:
            server.sendmail(msg['From'], msg['To'], msg.as_string())

        print(f"Email sent to {message['Email']}")

    return {
        'statusCode': 200,
        'body': json.dumps('Emails sent successfully')
    }