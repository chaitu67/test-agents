# GitHub Actions CI/CD Setup Guide

This guide walks you through setting up the GitHub Actions CI/CD pipeline for AWS CloudFormation deployment.

## Architecture Overview

The CI/CD pipeline includes:
1. **Validation**: Code quality, linting, and CloudFormation template validation
2. **Testing**: Unit tests and security checks
3. **Manual Approval**: For production deployments (requires PR review)
4. **Deployment**: CloudFormation stack creation/update to AWS
5. **Rollback**: Automatic rollback on deployment failure

## Prerequisites

- GitHub repository with admin access
- AWS Account (529088291603)
- AWS IAM credentials (already provided)

## Step 1: Add AWS Credentials to GitHub Secrets

1. Go to your GitHub repository: `https://github.com/chaitu67/test-agents`
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

Add the following secrets:

### Secret 1: AWS_ACCESS_KEY_ID
- **Name**: `AWS_ACCESS_KEY_ID`
- **Value**: `<your-aws-access-key-id>`
- Click **Add secret**

### Secret 2: AWS_SECRET_ACCESS_KEY
- **Name**: `AWS_SECRET_ACCESS_KEY`
- **Value**: `<your-aws-secret-access-key>`
- Click **Add secret**

## Step 2: Configure Branch Protection (Optional but Recommended)

1. Go to **Settings** → **Branches**
2. Under "Branch protection rules", click **Add rule**
3. Enter `main` as the branch name
4. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Require code reviews before merging (suggest 1 approval)
5. Click **Create**

## Step 3: Set Up Environment Protection (for Production)

1. Go to **Settings** → **Environments**
2. Click **New environment**
3. Name it `production`
4. Enable **Required reviewers** if you want manual approval before deployment
5. Add reviewers who can approve production deployments
6. Click **Configure protection rules**

## Step 4: Push Files to Repository

The following files have been created locally:

```
.github/
└── workflows/
    └── deploy.yaml              # Main CI/CD workflow

cloudformation/
├── template.yaml                # AWS CloudFormation template

scripts/
├── validate-cfn.sh              # CloudFormation validation script
└── validate-python.sh           # Python code validation script

tests/
└── test_sample.py               # Sample unit tests

requirements.txt                  # Python dependencies
README.md                         # Updated with setup instructions
```

Push these to your GitHub repository:

```bash
cd test-agents
git add .
git commit -m "Add GitHub Actions CI/CD pipeline with CloudFormation deployment"
git push origin main
```

## Step 5: Verify the Workflow

1. Go to your GitHub repository
2. Click on **Actions** tab
3. You should see the workflow running
4. Monitor the progress through each job:
   - ✅ **validate** - Code and CloudFormation validation
   - ✅ **test** - Unit tests
   - ⏳ **approval** - Awaits manual approval
   - ✅ **deploy** - Deploys to AWS

## Workflow Details

### Validation Job
- **Linting**: Checks Python code with flake8
- **Formatting**: Checks code formatting with black
- **CloudFormation**: Validates template syntax with cfn-lint
- **Security**: Runs bandit security checks
- **Unit Tests**: Runs pytest tests

### Test Job
- Installs dependencies from `requirements.txt`
- Runs pytest on the `tests/` directory
- Generates coverage reports
- Uploads to Codecov (if configured)

### Approval Job
- Triggered on push to `main` branch
- Requires manual approval via GitHub environment protection
- Reviewers must approve before deployment proceeds

### Deploy Job
- Checks if CloudFormation stack exists
- Creates new stack or updates existing stack
- Validates template with AWS CloudFormation service
- Performs post-deployment health checks
- Sends notifications on success/failure

### Rollback Job (Triggered on Failure)
- Automatically triggered if deployment fails
- Attempts to rollback to previous stable state
- Sends failure notifications

## CloudFormation Resources

The template deploys the following AWS resources to **us-east-1**:

### IAM Roles
- EC2/Lambda execution role with appropriate permissions
- Glue job execution role

### Compute
- **EC2 Instance** (t3.micro): Running Amazon Linux 2 with Python
- **Lambda Function**: Python 3.11 serverless function

### Storage
- **S3 Bucket**: With versioning and encryption enabled
- Bucket policy enforcing server-side encryption

### Secrets Management
- **AWS Secrets Manager**: Stores application credentials

### Data Processing
- **AWS Glue Database**: For data catalog and ETL operations

### Monitoring
- **CloudWatch Log Groups**: For Lambda and EC2 logs (30-day retention)

## Making Changes to the Workflow

### To modify deployment settings:
1. Edit `.github/workflows/deploy.yaml`
2. Update environment variables like `AWS_REGION`, `CLOUDFORMATION_STACK_NAME`
3. Commit and push to `main`

### To update CloudFormation resources:
1. Edit `cloudformation/template.yaml`
2. Add/remove/modify resource blocks
3. Commit and push to `main`
4. The workflow will validate and deploy changes

### To add more validation:
1. Edit `.github/workflows/deploy.yaml`
2. Add new steps to the `validate` job
3. The workflow will run these checks on every push

## Monitoring Deployments

### AWS Console
Visit the [CloudFormation dashboard](https://console.aws.amazon.com/cloudformation/) to:
- View stack status
- Check resource creation
- Monitor events and errors
- Access stack outputs

### GitHub Actions
Check the [Actions tab](https://github.com/chaitu67/test-agents/actions) to:
- View workflow execution history
- See detailed logs for each job
- Check validation and test results
- Approve pending deployments

## Troubleshooting

### Deployment Fails with "Invalid AWS credentials"
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correctly added to GitHub Secrets
- Ensure credentials have CloudFormation, EC2, Lambda, S3, Secrets Manager, and Glue permissions

### CloudFormation Template Validation Fails
- Run `scripts/validate-cfn.sh` locally to debug
- Check CloudFormation syntax with `cfn-lint cloudformation/template.yaml`

### Tests Fail
- Run `pytest tests/ -v` locally to debug
- Ensure all dependencies in `requirements.txt` are installed
- Check test logs in the GitHub Actions workflow

### Stack Stuck in UPDATE_IN_PROGRESS
- Go to AWS CloudFormation console
- Select the stack
- Perform a "Continue Update Rollback" if needed

## Security Best Practices

✅ **Implemented**:
- AWS credentials stored as GitHub Secrets (never in code)
- Manual approval required for production deployments
- S3 bucket with encryption and public access blocked
- IAM roles with least privilege access
- Secrets Manager for sensitive credentials
- CloudWatch logs for audit trails
- Code validation and security checks (bandit)

⚠️ **Next Steps**:
- Enable MFA for GitHub account
- Rotate AWS credentials periodically
- Use AWS IAM roles instead of access keys when possible
- Set up cost alerts for unexpected AWS charges
- Review CloudWatch logs regularly

## Cleanup (if needed)

To remove the CloudFormation stack and all deployed resources:

```bash
aws cloudformation delete-stack \
  --stack-name test-agents-stack \
  --region us-east-1
```

Or via GitHub Actions:
1. Manually trigger the workflow
2. The rollback job can be configured to clean up resources

## Support & Next Steps

1. **Monitor the first deployment** carefully in the Actions tab
2. **Review CloudFormation events** in the AWS console
3. **Check application logs** in CloudWatch
4. **Test manual approvals** by creating a test PR
5. **Customize resources** in `cloudformation/template.yaml` as needed

For questions or issues, check:
- GitHub Actions logs: https://github.com/chaitu67/test-agents/actions
- AWS CloudFormation console: https://console.aws.amazon.com/cloudformation/
- CloudFormation events for specific error messages
