#!/bin/bash
# shellcheck disable=SC2016,SC2086,SC2162
# This script can be used for release.

CENTRAL_BUCKET=aws-managed-cost-intelligence-dashboards
files=("data-exports-aggregation" "cur-aggregation")
for file in "${files[@]}"; do
    #Here data export stack and legacy cur aggregation have their own versions
    version=$(grep '^Description:' "data-exports/deploy/${file}.yaml" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')
    source_path="data-exports/deploy/${file}.yaml"
    echo $source_path
    aws s3 sync "$source_path" "s3://$CENTRAL_BUCKET/cfn/data-exports/$version/${file}.yaml"
    aws s3 sync "$source_path" "s3://$CENTRAL_BUCKET/cfn/data-exports/latest/${file}.yaml"
    aws s3 sync "$source_path" "s3://$CENTRAL_BUCKET/cfn/${file}.yaml"
done
