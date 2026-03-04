#!/bin/bash

# Clear problematic Google Cloud environment variables that might contain '$' characters
# Use this script in your Harness pipeline BEFORE the Terraform steps

echo "Clearing Google Cloud environment variables to avoid credential parsing errors..."

# Unset variables that might contain problematic characters
unset GOOGLE_APPLICATION_CREDENTIALS
unset GOOGLE_CREDENTIALS  
unset GOOGLE_CLOUD_KEYFILE_JSON
unset GCLOUD_KEYFILE_JSON

# Verify they are unset
echo "GOOGLE_APPLICATION_CREDENTIALS: ${GOOGLE_APPLICATION_CREDENTIALS:-'(unset)'}"
echo "GOOGLE_CREDENTIALS: ${GOOGLE_CREDENTIALS:-'(unset)'}"

echo "Environment variables cleared successfully."