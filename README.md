# GitHub Action: Validate & Apply GorillaStack Config

[GorillaStack](https://www.gorillastack.com) provides cost-optimization, backup and security superpowers for users to employ in their AWS environments. Customers drive configuration through the web application, API and more recently through a Terraform provider.

This action allows customers to keep the source of truth for their GorillaStack config in their repository, automatically validate templates on every push and apply them on a merge to master.

## Prerequisite - Create CloudFormation Stack to Persist tfstate

To maintain state in the `.tfstate` files generated by Terraform, we have provided a CloudFormation template to help users create an S3 bucket and a user with minimal privileges required to read/write to that bucket created.

**Note** Please do not modify the region or the stack name. When the action runs, it needs to look for a stack of that name in that region in order to get the generated bucket name from the CloudFormation outputs.

#### Deploy via AWSCLI

```bash
aws cloudformation deploy \
  --template-file https://gorillastack-cloudformation-templates.s3.amazonaws.com/github-action-bucket-template.yml \
  --stack-name github-actions-gorillastack-tfstate \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

#### Deploy via AWS Console

Click this button launch this stack in the AWS CloudFormation Console.

[![Launch Stack](https://cdn.rawgit.com/buildkite/cloudformation-launch-stack-button-svg/master/launch-stack.svg)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/quickcreate?stackName=github-actions-gorillastack-tfstate&templateUrl=https%3A%2F%2Fgorillastack-cloudformation-templates.s3.amazonaws.com%2Fgithub-action-bucket-template.yml)

You will need to check the box to confirm the creation of IAM resources in the template.


## Configuration - GitHub Secrets

There are 4 secrets that you will need to set in your GitHub repository to configure this action:

Secret Name | Purpose
------------ | -------------
AWS_ACCESS_KEY_ID | AWS Creds required to access the created S3 bucket to store and retrieve tfstate
AWS_SECRET_ACCESS_KEY | AWS Creds required to access the created S3 bucket to store and retrieve tfstate
GORILLASTACK_API_KEY | GorillaStack API Key, read-write or read-only, tied to your user identity
GORILLASTACK_TEAM_ID | GorillaStack Team Id, sets context of which team/tenant you are targeting

Within your GitHub repository, navigate to `Settings > Secrets` to set the secrets for this action.


#### 1. Create AWS Access Key

A user was created as part of the CloudFormation Stack deployed above. You will need to create access keys for this user, that you will then set as secrets in your GitHub repository.

Do this either via AWS CLI:

```bash
aws iam create-access-key --user-name github-actions-gorillastack-tfstate-user
```

or via AWS Console:

1. [Navigate to the IAM User configuration for the github-actions-gorillastack-tfstate-user](https://console.aws.amazon.com/iam/home?#/users/github-actions-gorillastack-tfstate-user?section=security_credentials)
1. Click on the "Create Access Key" button
1. Copy the "Access Key Id" and "Secret Access Key" from the modal


#### 2. Create GorillaStack API Key and finding your Team Id

If you have not used the GorillaStack API yet, [please follow this documentation to generate a key and retrieve the Team Id](https://docs.gorillastack.com/docs/reference/api/overview).


