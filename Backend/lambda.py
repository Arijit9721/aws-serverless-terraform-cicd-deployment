import boto3
import json
import os
import sys

# gathering the variables from terraform environment variables
try:
    dynamo_table = os.environ["dynamo_table"]
except KeyError as e:
    print(json.dumps({"error": f"Missing required environment variable: {str(e)}"}))
    sys.exit(1)

# Connecting to the aws resources 
try:
    dynamo = boto3.resource('dynamodb')
    dynamo_table_name = dynamo.Table(dynamo_table)
except Exception as e:
    print(json.dumps({"Error while accessing aws resources: ": f"{str(e)}"}))
    sys.exit(1)


# Function to increase views count when a new visitor visits the site
def lambda_handler(event, context):
    try:
        response = dynamo_table_name.update_item(
        Key = { 
            'websites': 'Portfolio_Website' # get the partition key/value to find the other attributes under it
        },
        UpdateExpression = "SET total_views = if_not_exists(total_views, :start) + :increment", # increment the total_views arttribute
        ExpressionAttributeValues={
            ':increment': 1,   # increment by 1
            ':start': 0
        },
        ReturnValues="UPDATED_NEW" # Return the new value after update
        )
        
    # printing the new value of views
        new_views = response['Attributes']['total_views']
        print(f"new view count: {int(new_views)}")    

    # returning the values to lambda url
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': "The view count was incremented successfully",
                'views': int(new_views)
            })
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
             'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': f"Error updating count: {str(e)}"
            })
        }

