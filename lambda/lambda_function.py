import os
import boto3
import json

s3 = boto3.client('s3')
sns = boto3.client('sns')

topic_arn = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        obj = s3.get_object(Bucket=bucket, Key=key)
        raw = obj['Body'].read()

        try:
            content = raw.decode('utf-8-sig')
        except UnicodeDecodeError:
            print("⚠️ UTF-8 decoding failed, trying fallback...")
            content = raw.decode('utf-16')

        print("✅ Decoded content:")
        print(content)

        try:
            data = json.loads(content)
        except Exception as e:
            print(f"❌ Error parsing JSON: {e}")
            return {"statusCode": 400, "body": "Invalid JSON"}

        print(f"🔍 Parsed JSON:\n{json.dumps(data, indent=2)}")

        message = f"📂 File: {key}\n📦 Content:\n{json.dumps(data, indent=2)}"

        if data.get('status') == 'approved':
            url = s3.generate_presigned_url('get_object', Params={'Bucket': bucket, 'Key': key}, ExpiresIn=600)
            message += f"\n🔗 Download link: {url}"

        sns.publish(
            TopicArn=topic_arn,
            Subject='New JSON Upload',
            Message=message
        )

        print("✅ SNS notification sent!")

        return {"statusCode": 200, "body": "Processed"}
