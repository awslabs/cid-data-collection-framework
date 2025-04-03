# Data Exports and Legacy CUR

## Table of Contents
- [Introduction](#introduction)
- [Data Exports](#data-exports)
  - [Basic Architecture](#basic-architecture-of-data-exports)
  - [Advanced Architecture](#advanced-architecture-of-data-exports)
- [Legacy Cost and Usage Report](#legacy-cost-and-usage-report)
- [FAQ](#faq)

## Introduction
This readme contains description of solutions for AWS Data Exports and Legacy CUR replication and consolidation across multiple accounts. This is a part of Cloud Intelligence Dashboards and it is recommended by [AWS Data Exports official documentation](https://docs.aws.amazon.com/cur/latest/userguide/dataexports-processing.html).

## Data Exports

For deployment instructions, please refer to the documentation at: https://catalog.workshops.aws/awscid/data-exports.  

Check code here: [data-exports-aggregation.yaml](deploy/data-exports-aggregation.yaml)


### Basic Architecture of Data Exports
![Basic Architecture of Data Exports](/.images/architecture-data-exports.png  "Basic Architecture of Data Exports")

1. [AWS Data Exports](https://aws.amazon.com/aws-cost-management/aws-data-exports/) delivers daily Cost & Usage Report (CUR2) and other reports to an [Amazon S3 Bucket](https://aws.amazon.com/s3/) in the Management Account.
2. [Amazon S3](https://aws.amazon.com/s3/) replication rule copies Export data to a dedicated Data Collection Account S3 bucket automatically.
3. [Amazon Athena](https://aws.amazon.com/athena/) allows querying data directly from the S3 bucket using an [AWS Glue](https://aws.amazon.com/glue/) table schema definition.
4. [Amazon QuickSight](https://aws.amazon.com/quicksight/) datasets can read from [Amazon Athena](https://aws.amazon.com/athena/). Check Cloud Intelligence Dashboards for more details.

### Advanced Architecture of Data Exports
For customers with additional requirements, an enhanced architecture is available:

![Advanced Architecture of Data Exports](/.images/architecture-data-exports-advanced.png  "Advanced Architecture of Data Exports")

1. [AWS Data Exports](https://aws.amazon.com/aws-cost-management/aws-data-exports/) service delivers [Cost & Usage Report (CUR2)](https://docs.aws.amazon.com/cur/latest/userguide/what-is-cur.html) daily to an [Amazon S3](https://aws.amazon.com/s3/) Bucket in your AWS Account (either in Management/Payer Account or a regular Linked Account). In us-east-1 region, the CloudFormation creates native resources; in other regions, CloudFormation uses AWS Lambda and Custom Resource to provision Data Exports in us-east-1.

2. [Amazon S3 replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html) rules copy Export data to a dedicated Data Collection Account automatically. This replication filters out all metadata and makes the file structure on the S3 bucket compatible with [Amazon Athena](https://aws.amazon.com/athena/) and [AWS Glue](https://aws.amazon.com/glue/) requirements.

3. A [Bucket Policy](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html) controls which accounts can replicate data to the destination bucket.

4. [AWS Glue Crawler](https://docs.aws.amazon.com/glue/latest/dg/components-overview.html#crawling-component) runs every midnight UTC to update the partitions of the table definition in [AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/components-overview.html#data-catalog-component).

5. [Amazon QuickSight](https://aws.amazon.com/quicksight/) pulls data from Amazon Athena to its SPICE (Super-fast, Parallel, In-memory Calculation Engine).

6. When collecting data exports for Linked accounts (not for Management Accounts), you may also want to collect data exports for the Data Collection account itself. In this case, specify the Data Collection account as the first in the list of Source Accounts. Replication is still required to remove metadata.

7. Athena's reading process can be affected by writing operations. When replication arrives, it might fail to update datasets, especially with high volumes of data. In such cases, consider scheduling temporary disabling and re-enabling of the Amazon S3 bucket policy that allows replication. Since exports typically arrive three times daily, this temporary deactivation has minimal side effects.

8. Some customers might need to store data exports to secondary destinations for archiving or reporting at a higher organizational level. You can specify a secondary bucket to receive the data in these cases.

## Legacy Cost and Usage Report
Legacy AWS Cost and Usage Reports (Legacy CUR) can still be used for Cloud Intelligence Dashboards and other use cases.

The CID project provides a CloudFormation template for Legacy CUR. Unlike the Data Exports CloudFormation template, it does not provide AWS Glue tables. You can use this template to replicate CUR and aggregate CUR from multiple source accounts (Management or Linked).

![Basic Architecture of CUR](/.images/architecture-legacy-cur.png  "Basic Architecture of CUR")


Check code here: [cur-aggregation.yaml](deploy/cur-aggregation.yaml)

## FAQ

### Why replicate data instead of providing cross-account access?
Cross-account access is possible but can be difficult to maintain, considering the many different roles that require this access, especially when dealing with multiple accounts.

### We only have one AWS Organization. Do we still need this?
Yes. Throughout an organization's lifecycle, mergers and acquisitions may occur, so this approach prepares you for potential future scenarios.