import json

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": json.dumps("Hello from lambda 3!")
        #"body": json.dumps("Updated Lambda Version!")
    }