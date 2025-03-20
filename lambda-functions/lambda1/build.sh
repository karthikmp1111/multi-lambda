#!/bin/bash

LAMBDA_NAME=$(basename "$PWD")

echo "Building $LAMBDA_NAME..."

# Install dependencies
pip install -r requirements.txt -t .

# Create zip package
zip -r package.zip . -x "build.sh" "*.pyc" "__pycache__/*"

echo "Build completed for $LAMBDA_NAME"
