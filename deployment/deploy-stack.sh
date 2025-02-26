#!/bin/bash

STACK_NAME=$1

if [[ -z "$STACK_NAME" ]]; then
  echo "Usage: $0 <stack-name>"
  exit 1
fi

# Define stack template mapping
declare -A STACK_TEMPLATES
STACK_TEMPLATES[networking]="templates/networking/networking.yaml"
STACK_TEMPLATES[security]="templates/security/security.yaml"
STACK_TEMPLATES[compute]="templates/compute/compute.yaml"
STACK_TEMPLATES[database]="templates/database/database.yaml"
STACK_TEMPLATES[storage]="templates/storage/storage.yaml"

# Check if stack exists in mapping
TEMPLATE_FILE=${STACK_TEMPLATES[$STACK_NAME]}
if [[ -z "$TEMPLATE_FILE" ]]; then
  echo "🚨 Unknown stack: $STACK_NAME. Available stacks: ${!STACK_TEMPLATES[@]}"
  exit 1
fi

# Deploy the CloudFormation stack
aws cloudformation deploy --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  --parameter-overrides file://templates/$STACK_NAME/params/dev-params.json \
  --capabilities CAPABILITY_NAMED_IAM

if [ $? -eq 0 ]; then
  echo "✅ Successfully deployed $STACK_NAME."
else
  echo "❌ Deployment failed for $STACK_NAME."
  exit 1
fi
