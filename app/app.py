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

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return float(o)
        return super(DecimalEncoder, self).default(o)


def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))

    method = event.get("httpMethod")
    path = event.get("path", "")
    path_params = event.get("pathParameters") or {}

    body = {}
    statusCode = 200

    try:
        if method == "GET" and path.endswith("/items") and not path_params:
            body = table.scan().get("Items", [])

        elif method == "GET" and (path_params.get("id") or path.startswith("/items/")):
            item_id = path_params.get("id") or path.split("/")[-1]
            resp = table.get_item(Key={'id': item_id})
            body = resp.get("Item", {})
            if not body:
                statusCode = 404
                body = {"error": f"Item {item_id} not found"}

        elif method == "PUT" and path.endswith("/items"):
            requestJSON = json.loads(event['body'])
            if "id" not in requestJSON:
                raise ValueError("Missing 'id' in request body")
            table.put_item(Item=requestJSON)
            body = {'message': f"Put item {requestJSON['id']}"}

        elif method == "DELETE" and (path_params.get("id") or path.startswith("/items/")):
            item_id = path_params.get("id") or path.split("/")[-1]
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
        "body": json.dumps(body, cls=DecimalEncoder)
    }


