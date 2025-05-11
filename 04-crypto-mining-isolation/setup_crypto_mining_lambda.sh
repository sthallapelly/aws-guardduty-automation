#!/bin/bash
set -e

# Package and deploy Lambda
zip lambda_isolate_instance.zip lambda_isolate_instance.py

ROLE_ARN=$(aws iam create-role \
  --role-name LambdaIsolateEC2Role \
  --assume-role-policy-document file://../shared/lambda_iam_policy.json \
  --query 'Role.Arn' --output text)

aws lambda create-function \
  --function-name isolateEC2onCryptoMining \
  --runtime python3.12 \
  --role "$ROLE_ARN" \
  --handler lambda_isolate_instance.lambda_handler \
  --zip-file fileb://lambda_isolate_instance.zip

# Create EventBridge rule
aws events put-rule \
  --name crypto-mining-detection \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"],
    "detail": {
      "type": ["CryptoCurrency:EC2/BitcoinTool.B!DNS"]
    }
  }'

# Attach Lambda as target
aws events put-targets \
  --rule crypto-mining-detection \
  --targets "[{\"Id\":\"1\",\"Arn\":\"$(aws lambda get-function --function-name isolateEC2onCryptoMining --query 'Configuration.FunctionArn' --output text)\"}]"

echo "Crypto mining detection Lambda setup complete."
