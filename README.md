# GuardDuty Automation with AWS CLI

## Overview
This project enables and automates AWS GuardDuty configurations and responses using production-grade CLI scripts.

## Features
- Single and Multi-Account Setup
- High-Severity Detection with SNS + Firehose
- Crypto Mining Isolation via Lambda
- Port Probe Detection with EC2 Auto-Tagging

## Setup

### Prerequisites
- AWS CLI configured
- IAM permissions to create GuardDuty, EventBridge, Lambda, SNS, Firehose, and EC2 actions

### Steps

1. Clone the repo and update with your account info as needed.
2. Execute each use case:
   ```bash
   cd 01-single-account-setup
   bash enable_guardduty_single_account.sh
``
### For detailed information on GuardDuty refer to my blog post 


