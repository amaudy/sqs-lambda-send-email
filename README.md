# POC-SQS

## Description
This is a simple POC to test SQS with Python.

```bash
aws sqs send-message \
    --queue-url $(terraform output -raw queue_url) \
    --message-body "Hello, SQS!" \
    --message-group-id "group1" \
    --message-deduplication-id "$(date +%s)"
```