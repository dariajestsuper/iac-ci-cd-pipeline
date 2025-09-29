import json
import boto3
import os
from decimal import Decimal

client = boto3.client('lambda')
dynamodb = boto3.resource(
    "dynamodb",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    endpoint_url=os.getenv("DYNAMODB_ENDPOINT")
)

table = dynamodb.Table('items_table')


def lambda_handler(event, context):
    print(event)
    method = event["httpMethod"]
    resource = event["resource"]
    body = {}
    statusCode = 200

    try:
        if method == "GET" and resource == "/items/{id}":
            item_id = event["pathParameters"]["id"]
            body = table.get_item(Key={'id': item_id})
            body = body["Item"]
        elif method == "GET" and resource == "/items":
            body = table.scan()["Items"]
        elif method == "PUT" and resource == "/items":
            requestJSON = json.loads(event['body'])
            table.put_item(Item=requestJSON)
            body = {'message': f"Put item {requestJSON['id']}"}
        elif method == "DELETE" and resource == "/items/{id}":
            item_id = event["pathParameters"]["id"]
            table.delete_item(Key={'id': item_id})
            body = {'message': f"Deleted item {item_id}"}
        else:
            statusCode = 400
            body = {'error': 'Unsupported route'}
    except Exception as e:
        statusCode = 500
        body = {'error': str(e)}

    return {
        "statusCode": statusCode,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body)
    }

