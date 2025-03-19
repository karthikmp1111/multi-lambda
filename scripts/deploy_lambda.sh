#!/bin/bash

set -e

LAMBDA_NAME=$1

echo "Deleting all versions of $LAMBDA_NAME..."

# Get all Lambda versions except $LATEST
VERSIONS=$(aws lambda list-versions-by-function --function-name $LAMBDA_NAME --query 'Versions[*].Version' --output text | tr '\t' '\n' | grep -v '\$LATEST')

# Delete each version
for VERSION in $VERSIONS; do
    aws lambda delete-function --function-name $LAMBDA_NAME --qualifier $VERSION
done

# Delete the Lambda function
aws lambda delete-function --function-name $LAMBDA_NAME

echo "$LAMBDA_NAME deleted successfully!"
