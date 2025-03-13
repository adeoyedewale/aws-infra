#!/bin/bash

STACK_NAME=$1

# ANSI Color Codes
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RESET='\e[0m'


if [[ -z "$STACK_NAME" ]]; then
  echo -e "${RED}Usage: $0 <stack-name>${RESET}"
  exit 1
fi

# Define stack template mapping
declare -A STACK_TEMPLATES
STACK_TEMPLATES[networking]="templates/networking/networking.yaml"
STACK_TEMPLATES[security]="templates/security/security.yaml"
STACK_TEMPLATES[routes]="templates/routes/routes.yaml"
STACK_TEMPLATES[security-groups]="templates/security-groups/security-groups.yaml"
STACK_TEMPLATES[storage]="templates/storage/storage.yaml"

# Check if stack exists in mapping
TEMPLATE_FILE=${STACK_TEMPLATES[$STACK_NAME]}
if [[ -z "$TEMPLATE_FILE" ]]; then
  echo -e "${RED}Unknown stack: $STACK_NAME. Available stacks: ${!STACK_TEMPLATES[@]}${RESET}"
  exit 1
fi

# Check if a parameter file exists for the stack
PARAMS_FILE="templates/$STACK_NAME/params/dev-params.json"
if [[ -f "$PARAMS_FILE" ]]; then
  echo -e "${CYAN}Using parameter file: $PARAMS_FILE${RESET}"
  PARAM_OVERRIDE="--parameter-overrides file://$PARAMS_FILE"
else
  echo -e "${YELLOW}No parameter file found for $STACK_NAME, skipping parameters.${RESET}"
  PARAM_OVERRIDE=""
fi

# Deploy the CloudFormation stack
aws cloudformation deploy --stack-name "$STACK_NAME" \
  --template-file "$TEMPLATE_FILE" \
  $PARAM_OVERRIDE \
  --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Successfully deployed $STACK_NAME.${RESET}"
else
  echo -e "${RED}Deployment failed for $STACK_NAME.${RESET}"
  exit 1
fi
