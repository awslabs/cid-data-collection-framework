#!/bin/bash
# shellcheck disable=SC2016,SC2086,SC2162
# This script can be used for release

export CENTRAL_BUCKET=aws-managed-cost-intelligence-dashboards

code_path=$(git rev-parse --show-toplevel)/data-exports/deploy
version=$(jq -r .version data-collection/utils/version.json)

echo "sync files"
aws s3 sync $code_path/       s3://$CENTRAL_BUCKET/cfn/data-exports/$version/ --delete
aws s3 sync $code_path/       s3://$CENTRAL_BUCKET/cfn/data-exports/latest/ --delete
aws s3 sync $code_path/       s3://$CENTRAL_BUCKET/cfn/ #legacy location