# Test Agents

GitHub Actions CI/CD pipeline with AWS CloudFormation deployment for the test-agents project.

## Quick Start

### 1. Add AWS Credentials to GitHub Secrets

Go to https://github.com/chaitu67/test-agents/settings/secrets/actions and add:
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

### 2. Push to Main Branch

The GitHub Actions workflow will automatically:
1. Validate code and CloudFormation templates
2. Run unit tests
3. Await manual approval
4. Deploy to AWS using CloudFormation
5. Perform health checks
6. Rollback on failure

### 3. Monitor Deployment

Check the [Actions tab](https://github.com/chaitu67/test-agents/actions) to:
- View workflow progress
- Approve deployments (manual approval required)
- Review validation and test results

## Project Structure

```
test-agents/
├── .github/workflows/
│   └── deploy.yaml                 # Main CI/CD workflow
├── cloudformation/
│   └── template.yaml               # AWS CloudFormation template
├── scripts/
│   ├── validate-cfn.sh             # Validate CloudFormation
│   └── validate-python.sh          # Validate Python code
├── tests/
│   └── test_sample.py              # Unit tests
├── requirements.txt                 # Python dependencies
├── SETUP.md                        # Detailed setup guide
└── README.md                       # This file
```

## Deployed AWS Resources

| Resource | Type | Details |
|----------|------|---------|
| **EC2 Instance** | Compute | t3.micro Amazon Linux 2 |
| **Lambda Function** | Compute | Python 3.11 serverless |
| **S3 Bucket** | Storage | Versioning enabled, encrypted |
| **Secrets Manager** | Security | Application credentials |
| **IAM Roles** | Security | Least privilege access |
| **Glue Database** | Data | AWS Glue data catalog |
| **CloudWatch Logs** | Monitoring | 30-day retention |

## Workflow Steps

### 1. Validation
- ✅ Python linting (flake8)
- ✅ Code formatting check (black)
- ✅ CloudFormation validation (cfn-lint)
- ✅ Security checks (bandit)
- ✅ Unit tests (pytest)

### 2. Testing
- ✅ Run pytest test suite
- ✅ Generate coverage reports
- ✅ Upload to Codecov

### 3. Approval
- ⏳ Wait for manual approval (required for production)
- ⏳ Reviewers must approve via GitHub environment protection

### 4. Deployment
- ✅ Validate CloudFormation with AWS
- ✅ Create or update CloudFormation stack
- ✅ Deploy EC2, Lambda, S3, IAM, Secrets Manager, Glue
- ✅ Post-deployment health checks
- ✅ Send notifications

### 5. Rollback (on failure)
- 🔄 Automatic rollback on deployment failure
- 🔄 Failure notifications sent

## Configuration

### Environment Variables

Edit `.github/workflows/deploy.yaml` to customize:

```yaml
env:
  ENVIRONMENT: prod              # Environment name
  AWS_REGION: us-east-1          # AWS region
  CLOUDFORMATION_STACK_NAME: test-agents-stack
```

### CloudFormation Parameters

Edit `cloudformation/template.yaml`:

```yaml
Parameters:
  InstanceType:
    Default: t3.micro            # Change EC2 instance type
  Environment:
    Default: prod                # Change environment
```

## Running Locally

### Validate CloudFormation
```bash
./scripts/validate-cfn.sh
```

### Validate Python Code
```bash
./scripts/validate-python.sh
```

### Run Tests
```bash
pip install -r requirements.txt
pytest tests/ -v
```

## Monitoring

### GitHub Actions
- Check workflow status: https://github.com/chaitu67/test-agents/actions
- View deployment logs: Click on workflow run

### AWS Console
- CloudFormation: https://console.aws.amazon.com/cloudformation/
- EC2 Instances: https://console.aws.amazon.com/ec2/
- Lambda Functions: https://console.aws.amazon.com/lambda/
- S3 Buckets: https://s3.console.aws.amazon.com/
- CloudWatch Logs: https://console.aws.amazon.com/logs/

## Deploying Changes

1. **Edit** code or template files
2. **Commit** with a descriptive message
3. **Push** to `main` branch
4. **GitHub Actions** automatically validates and tests
5. **Manual approval** required to proceed with deployment
6. **Deployment** to AWS occurs after approval

Example:
```bash
git checkout main
git pull origin main
# Make your changes
git add .
git commit -m "Update CloudFormation template with new resources"
git push origin main
```

## Manual Approval Process

1. Go to https://github.com/chaitu67/test-agents/actions
2. Click on the workflow run that's waiting
3. Click **Review deployments**
4. Approve the `production` environment
5. Deployment will proceed automatically

## Rollback

If a deployment fails:
1. Automatic rollback is triggered
2. Failed changes are rolled back to previous state
3. Notification is posted to GitHub
4. Manual intervention instructions provided in logs

To manually rollback:
```bash
aws cloudformation cancel-update-stack \
  --stack-name test-agents-stack \
  --region us-east-1
```

## Updating Workflows

### To add new validation:
1. Edit `.github/workflows/deploy.yaml`
2. Add steps to `validate` or `test` job
3. Push to `main`

### To update resources:
1. Edit `cloudformation/template.yaml`
2. Add/remove/modify resources
3. Push to `main`
4. Approve deployment when prompted

### To change deployment regions:
1. Edit `.github/workflows/deploy.yaml`
2. Change `AWS_REGION` environment variable
3. Update CloudFormation template if needed
4. Push to `main`

## Security Notes

⚠️ **Important**:
- Never commit AWS credentials to the repository
- Rotate credentials periodically
- Use GitHub Secrets for all sensitive data
- Review IAM permissions regularly
- Monitor CloudWatch logs for suspicious activity

## Troubleshooting

### Deployment stuck in "Await Approval"
- Check if environment protection is configured correctly
- Verify reviewers have permission to approve
- Go to repository Settings → Environments → production

### CloudFormation validation fails
- Run local validation: `./scripts/validate-cfn.sh`
- Check template syntax with AWS CLI: `aws cloudformation validate-template --template-body file://cloudformation/template.yaml`

### AWS credentials invalid
- Verify secrets in GitHub: Settings → Secrets and variables
- Confirm credentials have required IAM permissions
- Check credential expiration

## Support

For detailed setup instructions, see [SETUP.md](SETUP.md)

For AWS CloudFormation documentation, see: https://docs.aws.amazon.com/cloudformation/

For GitHub Actions documentation, see: https://docs.github.com/en/actions

## License

This project is open source and available under the MIT License.

---

**Last Updated**: March 15, 2026  
**Maintained by**: Chaitanya Varmamudundi
