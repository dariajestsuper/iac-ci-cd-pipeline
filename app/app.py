from flask import Flask, jsonify, request
import boto3
import uuid
import os
from botocore.exceptions import ClientError

app = Flask(__name__)

dynamodb = boto3.resource(
    "dynamodb",
    region_name=os.getenv("AWS_DEFAULT_REGION"),
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=os.getenv("AWS_SECRET_ACCESS_KEY"),
    endpoint_url=os.getenv("DYNAMODB_ENDPOINT")
)

table = dynamodb.Table('items_table')

@app.route('/items', methods=['POST'])
def add_item():
    data = request.get_json()
    if not data or "item" not in data:
        return jsonify({"error": "Missing 'item' in request body"}), 400

    item_id = str(uuid.uuid4())
    new_item = {
        "id": item_id,
        "item": data["item"]
    }

    try:
        table.put_item(Item=new_item)
        return jsonify(new_item), 201
    except ClientError as e:
        return jsonify({"error": str(e)}), 500

@app.route('/items', methods=['GET'])
def get_items():
    try:
        response = table.scan()
        return jsonify(response.get('Items', [])), 200
    except ClientError as e:
        return jsonify({'error': str(e)}), 500

@app.route('/items/<item_id>', methods=['GET'])
def get_item(item_id):
    try:
        response = table.get_item(Key={'id': item_id})
        return jsonify(response.get('Item', {})), 200
    except ClientError as e:
        return jsonify({'error': str(e)}), 500

@app.route('/items/<item_id>', methods=['DELETE'])
def delete_item(item_id):
    try:
        table.delete_item(Key={'id': item_id})
        return jsonify({'message': 'Item deleted'}), 200
    except ClientError as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug = True)