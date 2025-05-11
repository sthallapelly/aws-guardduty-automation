#!/bin/bash
set -e

zip lambda_tag_ec2.zip lambda_tag_ec2.py

ROLE_ARN=$(aws iam create-role \
  --role-name LambdaTagEC2Role \
  --assume-role-policy-document file://../shared/lambda_iam_policy.json \
  --query 'Role.Arn' --output text)

aws lambda create-function \
  --function-name tagEC2onPortProbing \
  --runtime python3.12 \
  --role "$ROLE_ARN" \
  --handler lambda_tag_ec2.lambda_handler \
  --zip-file fileb://lambda_tag_ec2.zip

aws events put-rule \
  --name port-probing-detection \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"],
    "detail": {
      "type": ["Recon:EC2/PortProbeUnprotectedPort"]
    }
  }'

aws events put-targets \
  --rule port-probing-detection \
  --targets "[{\"Id\":\"1\",\"Arn\":\"$(aws lambda get-function --function-name tagEC2onPortProbing --query 'Configuration.FunctionArn' --output text)\"}]"

echo "Port probing detection Lambda setup complete."
