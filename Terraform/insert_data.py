import boto3
import sys
import json
import os

# retrieving the environment variables from terraform
try:
    table_name = os.environ["table_name"]
    hash_key  = os.environ["hash_key"]
    second_key  = os.environ["second_key"]
except KeyError as e:
    print(json.dumps({"error": f"Missing required environment variable: {str(e)}"}))
    sys.exit(1)

# accessing the aws resources
try:
    dynamodb  = boto3.resource('dynamodb')
    dynamo_table = dynamodb.Table(table_name)

    # putting the items to the table
    dynamo_table.put_item(
        Item = {
            hash_key: "Portfollio_Webiste",
            second_key: 1,
        }
    )
    print("Succcessfully inserted the values to Dynamodb")
except Exception as e:
    print(json.dumps({"error": f"DynamoDb Error: {str(e)}"}))
    sys.exit(1)
