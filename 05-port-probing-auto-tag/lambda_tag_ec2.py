import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']

    ec2.create_tags(
        Resources=[instance_id],
        Tags=[{"Key": "Status", "Value": "Compromised"}]
    )
    print(f"Tagged instance {instance_id} as Compromised")
    return {"status": "Tag applied"}
