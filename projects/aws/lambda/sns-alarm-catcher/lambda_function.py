import json

def lambda_handler(event, context):
    # SNS hands us the message wrapped inside event["Records"]
    message = event["Records"][0]["Sns"]["Message"]
    subject = event["Records"][0]["Sns"].get("Subject", "no subject")

    print("ALARM CAUGHT BY LAMBDA")
    print("Subject:", subject)
    print("Message:", message)

    return {"statusCode": 200}