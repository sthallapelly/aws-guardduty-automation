#!/bin/bash
set -e
echo "Deleting GuardDuty"
aws guardduty delete-detector --detector-id $(aws guardduty list-detectors --query 'DetectorIds[0]' --output text)
echo "Delete Success"