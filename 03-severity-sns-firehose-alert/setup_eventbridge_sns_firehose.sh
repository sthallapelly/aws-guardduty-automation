#!/bin/bash
set -e

# Create SNS topic and get ARN
SNS_TOPIC_NAME="guardduty-high-severity-alerts"
SNS_TOPIC_ARN=$(aws sns create-topic --name "$SNS_TOPIC_NAME" --query 'TopicArn' --output text)
echo "Created SNS Topic: $SNS_TOPIC_ARN"

# Create Firehose delivery stream (assuming delivery role and bucket are pre-created)
FIREHOSE_NAME="guardduty-logs-firehose"
aws firehose create-delivery-stream \
  --delivery-stream-name "$FIREHOSE_NAME" \
  --delivery-stream-type DirectPut \
  --s3-destination-configuration file://firehose_delivery_stream_policy.json

# Wait until Firehose is active
echo "Waiting for Firehose to become ACTIVE..."
aws firehose wait delivery-stream-active --delivery-stream-name "$FIREHOSE_NAME"
FIREHOSE_ARN=$(aws firehose describe-delivery-stream \
  --delivery-stream-name "$FIREHOSE_NAME" \
  --query 'DeliveryStreamDescription.DeliveryStreamARN' --output text)
echo "Created Firehose Stream: $FIREHOSE_ARN"

# Create EventBridge rule for GuardDuty severity >= 7
RULE_NAME="guardduty-severity-high"
aws events put-rule \
  --name "$RULE_NAME" \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"],
    "detail": {
      "severity": [{"numeric": [">=", 7]}]
    }
  }'
echo "EventBridge rule created: $RULE_NAME"

# Add SNS and Firehose as targets
aws events put-targets \
  --rule "$RULE_NAME" \
  --targets "[
    {\"Id\": \"snsTarget\", \"Arn\": \"$SNS_TOPIC_ARN\"},
    {\"Id\": \"firehoseTarget\", \"Arn\": \"$FIREHOSE_ARN\"}
  ]"

echo "SNS and Firehose targets added to EventBridge rule."