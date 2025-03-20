#!/bin/bash

LAMBDA_NAME=$(basename "$PWD")

echo "Building $LAMBDA_NAME..."

# Check if requirements.txt exists before installing dependencies
if [[ ! -f requirements.txt ]]; then
    echo "Error: requirements.txt not found in $PWD"
    exit 1
fi

# Install dependencies
pip install -r requirements.txt -t .

# Remove any old zip package
rm -f package.zip

# Create zip package (excluding unnecessary files)
zip -r package.zip . -x "build.sh" "*.pyc" "__pycache__/*"

echo "Build completed for $LAMBDA_NAME"
