#!/bin/zsh
# This script uploads CloudFormation files to S3 bucket. Can be used with any testing bucket or prod.
# see also README.md

if [ -n "$1" ]; then
  bucket=$1
else
  echo "ERROR: First parameter not supplied. Provide a bucket name. aws-well-architected-labs for prod aws-wa-labs-staging for stage "
  echo " prod  aws-well-architected-labs "
  echo " stage aws-wa-labs-staging"
  exit 1
fi
folder=$(pwd)
code_path=$(git rev-parse --show-toplevel)/Data_Collection/Optimization/Code

echo "Sync to $bucket" # sync is faster than copy as it does not upload if already there
aws s3 sync $code_path/       s3://$bucket/Cost/Labs/300_Optimization_Data_Collection/ --exclude='*' --include='*.yaml' # --acl public-read
aws s3 sync $code_path/source s3://$bucket/Cost/Labs/300_Optimization_Data_Collection/Region/ --exclude='*' --include='regions.csv' # --acl public-read
aws s3 sync $code_path/source s3://$bucket/Cost/Labs/300_Optimization_Data_Collection/graviton/ --exclude='*' --include='rds_graviton_mapping.csv' # --acl public-read

echo 'Done'
cd $pwd