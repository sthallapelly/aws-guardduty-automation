import json
import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instance_id = event['detail']['resource']['instanceDetails']['instanceId']

    print(f"Isolating instance: {instance_id}")
    ec2.modify_instance_attribute(InstanceId=instance_id, Groups=[])
    return {"status": "Instance isolated"}
