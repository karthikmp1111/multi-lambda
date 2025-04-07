#!/bin/bash
set -e

echo "🔍 Checking which Lambda functions have changed..."

if git rev-parse HEAD~1 >/dev/null 2>&1; then
    CHANGED_FILES=$(git diff --name-only HEAD~1 HEAD)
else
    echo "⚠️ No previous commit found. Assuming all lambdas may have changed."
    CHANGED_FILES=$(git ls-files)
fi

CHANGED_LAMBDAS=$(echo "$CHANGED_FILES" | awk -F/ '/^lambda-functions\// {print $2}' | sort -u)

if [[ -z "$CHANGED_LAMBDAS" ]]; then
    echo "✅ No Lambda function changes detected. Skipping builds."
    exit 0
fi

echo "📦 Changed Lambdas: $CHANGED_LAMBDAS"

# Build and upload each changed Lambda
for lambda in $CHANGED_LAMBDAS; do
    echo "➡️ Building lambda-functions/$lambda"
    (cd "lambda-functions/$lambda" && ./build.sh)

    echo "⬆️ Uploading lambda-functions/$lambda/package.zip to S3..."
    aws s3 cp "lambda-functions/$lambda/package.zip" "s3://$S3_BUCKET/lambda-packages/$lambda/package.zip"
done