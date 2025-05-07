import json
import uuid
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("trade_logs")

def lambda_handler(event, context):
    method = event.get("httpMethod", event.get("requestContext", {}).get("http", {}).get("method"))

    if method == "POST":
        return save_trade(event)
    elif method == "GET":
        return list_trades(event)
    else:
        return {
            "statusCode": 405,
            "body": json.dumps({"error": "Method Not Allowed"})
        }

def save_trade(event):
    body = json.loads(event["body"])
    
    trade_id = str(uuid.uuid4())
    name = body.get("name")
    status = body.get("status")
    timestamp = body.get("timestamp")
    
    # Optional fields for trade details
    ticket = body.get("ticket", trade_id)
    open_time = body.get("open_time")
    close_time = body.get("close_time")
    trade_type = body.get("type")
    size = Decimal(str(body.get("size", "0.0")))
    item = body.get("item")
    price = Decimal(str(body.get("price", "0.0")))
    sl = Decimal(str(body.get("s/l", "0.0")))
    tp = Decimal(str(body.get("t/p", "0.0")))
    profit = Decimal(str(body.get("profit", "0.0")))

    # Save to DynamoDB
    table.put_item(
        Item={
            "trade_id": trade_id,
            "ticket": ticket,
            "name": name,
            "status": status,
            "timestamp": timestamp,
            "open_time": open_time,
            "close_time": close_time,
            "type": trade_type,
            "size": size,
            "item": item,
            "price": price,
            "s/l": sl,
            "t/p": tp,
            "profit": profit
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Trade saved", "trade_id": trade_id})
    }

def list_trades(event):
    try:
        status = event.get("queryStringParameters", {}).get("status")

        # Filter with alias for "status" (reserved keyword)
        if status:
            response = table.scan(
                FilterExpression="#s = :s",
                ExpressionAttributeNames={"#s": "status"},
                ExpressionAttributeValues={":s": status}
            )
        else:
            response = table.scan()

        # Convert Decimal to string for JSON serialization
        items = response["Items"]
        for item in items:
            for key, value in item.items():
                if isinstance(value, Decimal):
                    item[key] = str(value)

        return {
            "statusCode": 200,
            "body": json.dumps(items)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
