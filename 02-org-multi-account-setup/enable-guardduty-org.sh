#!/bin/bash
set -e

MASTER_DETECTOR_ID=$(aws guardduty create-detector --enable --query 'DetectorId' --output text)

## Replace <ORG_ADMIN_ACCOUNT_ID> with your org admin account.
echo "Delegating admin..."
aws guardduty enable-organization-admin-account --admin-account-id 123456789012

echo "Auto-enabling new org accounts..."
aws guardduty update-organization-configuration --detector-id "$MASTER_DETECTOR_ID" \
  --auto-enable ORGANIZATION \
  --data-sources '{"S3Logs":{"AutoEnable":true},"Kubernetes":{"AuditLogs":{"AutoEnable":true}}}'

echo "Add existing members"
aws guardduty create-members  \
  --detector-id "$MASTER_DETECTOR_ID" \
  --account-details AccountId=098765432109, Email=youreamil.example.com

echo "Multi-account GuardDuty setup complete."
