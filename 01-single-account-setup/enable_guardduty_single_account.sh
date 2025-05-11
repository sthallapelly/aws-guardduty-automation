#!/bin/bash
set -e

echo "Enabling GuardDuty in current region..."
aws guardduty create-detector --enable

DETECTOR_ID=$(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)

echo "Enabling S3 Protection..."
aws guardduty update-detector --detector-id "$DETECTOR_ID" --data-sources '{"S3Logs":{"Enable":true}}'

echo "Enabling EKS Protection..."
aws guardduty update-detector --detector-id "$DETECTOR_ID" \
  --data-sources '{"Kubernetes":{"AuditLogs":{"Enable":true}}}'

echo "GuardDuty setup complete for single account."
