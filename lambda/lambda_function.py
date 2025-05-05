import json
import boto3
import os

def lambda_handler(event, context):
    # 1. Extract bucket + key from S3 event
    try:
        record = event['Records'][0]
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
    except Exception as e:
        print(f"Malformed event: {e}")
        return {"statusCode": 400, "body": "Malformed event"}

    # 2. Read file from S3
    s3 = boto3.client('s3')
    try:
        obj = s3.get_object(Bucket=bucket, Key=key)
        file_content = obj['Body'].read().decode('utf-8')
        json_data = json.loads(file_content)
    except Exception as e:
        print(f"Error reading or decoding file: {e}")
        return {"statusCode": 400, "body": "Invalid file content"}

    # 3. Validate required fields
    required = ['name', 'status', 'timestamp']
    missing = [f for f in required if f not in json_data]
    if missing:
        print(f"Missing required fields: {missing}")
        return {"statusCode": 422, "body": f"Missing fields: {', '.join(missing)}"}

    # 4. Publish to SNS
    sns = boto3.client('sns')
    topic_arn = os.environ['SNS_TOPIC_ARN']
    message = f"{json_data['name']} submitted status '{json_data['status']}' at {json_data['timestamp']}"

    try:
        sns.publish(TopicArn=topic_arn, Message=message, Subject="JSON Upload Processed")
    except Exception as e:
        print(f"Failed to publish to SNS: {e}")
        return {"statusCode": 500, "body": "SNS publish failed"}

    return {"statusCode": 200, "body": "Success"}
