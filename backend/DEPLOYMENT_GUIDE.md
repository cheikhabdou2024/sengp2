# AWS Elastic Beanstalk Deployment Guide

## Prerequisites

1. AWS Account with appropriate permissions
2. AWS CLI configured with your credentials
3. EB CLI installed (instructions below)

## Step 1: Install EB CLI

### On Linux/WSL:
```bash
# Install pipx if not already installed
sudo apt update
sudo apt install -y pipx
pipx ensurepath

# Install EB CLI
pipx install awsebcli
```

### On macOS:
```bash
brew install awsebcli
```

### On Windows:
```powershell
pip install awsebcli --user
```

### Verify installation:
```bash
eb --version
```

## Step 2: Configure AWS Credentials

If you haven't already, configure your AWS credentials:
```bash
aws configure
```

You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., eu-west-1, us-east-1)
- Default output format (json)

## Step 3: Initialize Elastic Beanstalk Application

Navigate to the backend directory and initialize:
```bash
cd /mnt/c/Users/abdou/Desktop/sengp/backend

# Initialize EB application
eb init

# Follow the prompts:
# 1. Select region (e.g., eu-west-1)
# 2. Create new application: sengp-backend
# 3. Select platform: Docker
# 4. Docker platform branch: Docker running on 64bit Amazon Linux 2
# 5. Setup SSH: yes (recommended)
```

## Step 4: Create Database (RDS)

You need a PostgreSQL database. You can:

### Option A: Use existing database
Configure the DATABASE_URL in environment variables (Step 5)

### Option B: Create RDS instance with EB
```bash
# Create environment with RDS
eb create sengp-backend-prod --database \
  --database.engine postgres \
  --database.instance db.t3.micro \
  --database.username admin \
  --database.password YOUR_SECURE_PASSWORD
```

### Option C: Create RDS separately
1. Go to AWS RDS Console
2. Create PostgreSQL database
3. Note the endpoint, username, and password
4. Ensure security groups allow EB instances to connect

## Step 5: Set Environment Variables

Create a file `env.yaml` with your production environment variables:
```yaml
option_settings:
  aws:elasticbeanstalk:application:environment:
    NODE_ENV: production
    PORT: 5000
    API_VERSION: v1

    # Database - Use your actual values
    DATABASE_URL: postgresql://username:password@host:5432/database
    # Or individual variables
    DB_HOST: your-rds-endpoint.rds.amazonaws.com
    DB_PORT: 5432
    DB_NAME: sengp_db
    DB_USER: admin
    DB_PASSWORD: your_password
    DB_SSL: true

    # JWT
    JWT_SECRET: your-super-secret-jwt-key-change-this-in-production
    JWT_REFRESH_SECRET: your-refresh-secret-key
    JWT_EXPIRES_IN: 24h
    JWT_REFRESH_EXPIRES_IN: 7d

    # Redis (optional - use ElastiCache if needed)
    REDIS_HOST: your-elasticache-endpoint.amazonaws.com
    REDIS_PORT: 6379

    # AWS S3
    AWS_ACCESS_KEY_ID: your-access-key
    AWS_SECRET_ACCESS_KEY: your-secret-key
    AWS_REGION: eu-west-1
    AWS_S3_BUCKET: sengp-storage

    # Email (SendGrid)
    SENDGRID_API_KEY: your-sendgrid-api-key
    FROM_EMAIL: noreply@sengp.com
    FROM_NAME: SEN GP

    # SMS (Twilio)
    TWILIO_ACCOUNT_SID: your-twilio-account-sid
    TWILIO_AUTH_TOKEN: your-twilio-auth-token
    TWILIO_PHONE_NUMBER: +1234567890

    # Add other environment variables as needed
```

Set the environment variables:
```bash
eb setenv $(cat env.yaml | grep -v '^#' | grep -v '^$' | xargs)
```

Or set them individually:
```bash
eb setenv NODE_ENV=production \
  DATABASE_URL=postgresql://user:pass@host:5432/db \
  JWT_SECRET=your-secret
```

## Step 6: Create and Deploy Environment

### Option 1: Create new environment (if not created with database)
```bash
eb create sengp-backend-prod \
  --instance-type t3.small \
  --platform docker \
  --region eu-west-1
```

### Option 2: Deploy to existing environment
```bash
eb deploy sengp-backend-prod
```

## Step 7: Monitor Deployment

```bash
# Check environment status
eb status

# View logs
eb logs

# Open application in browser
eb open

# SSH into instance (if needed)
eb ssh
```

## Step 8: Configure Domain (Optional)

1. Go to Elastic Beanstalk Console
2. Select your environment
3. Go to Configuration > Load Balancer
4. Add HTTPS listener with SSL certificate
5. Update Route 53 or your DNS provider to point to EB URL

## Post-Deployment Checklist

- [ ] Verify application is running: `eb status`
- [ ] Check health: `eb health`
- [ ] Test API endpoints
- [ ] Verify database connection
- [ ] Check logs for errors: `eb logs`
- [ ] Set up CloudWatch alarms
- [ ] Configure auto-scaling if needed
- [ ] Set up continuous deployment (optional)

## Useful Commands

```bash
# View environment info
eb status

# Open app in browser
eb open

# View logs
eb logs

# SSH into instance
eb ssh

# Scale instances
eb scale 2

# Terminate environment (careful!)
eb terminate sengp-backend-prod

# List environments
eb list

# Update environment variables
eb setenv VAR_NAME=value

# Deploy after making changes
eb deploy
```

## Troubleshooting

### Application won't start
```bash
# Check logs
eb logs

# SSH and check Docker
eb ssh
sudo docker ps
sudo docker logs <container-id>
```

### Database connection issues
- Verify RDS security group allows inbound from EB security group
- Check DATABASE_URL or DB_* environment variables
- Ensure DB_SSL=true for RDS

### Environment health is degraded
```bash
eb health --refresh
eb logs
```

## Cost Optimization

- Use t3.micro or t3.small for development
- Enable auto-scaling based on load
- Use RDS t3.micro for development
- Consider Reserved Instances for production
- Set up automatic snapshots for RDS

## Security Best Practices

- Never commit `.env` files
- Use IAM roles instead of access keys when possible
- Enable SSL/HTTPS
- Keep dependencies updated
- Enable CloudWatch logging
- Use VPC with private subnets for RDS
- Enable RDS encryption
- Regular security patches
