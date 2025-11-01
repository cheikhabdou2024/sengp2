#!/bin/bash

# AWS Elastic Beanstalk Deployment Script
# This script helps automate the deployment process

set -e

echo "======================================"
echo "AWS Elastic Beanstalk Deployment"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if EB CLI is installed
if ! command -v eb &> /dev/null; then
    echo -e "${RED}Error: EB CLI is not installed${NC}"
    echo "Please install it first:"
    echo "  pipx install awsebcli"
    echo "  or"
    echo "  pip install awsebcli --user"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials not configured${NC}"
    echo "Please run: aws configure"
    exit 1
fi

echo -e "${GREEN}✓ EB CLI is installed${NC}"
echo -e "${GREEN}✓ AWS credentials are configured${NC}"
echo ""

# Check if EB is initialized
if [ ! -d ".elasticbeanstalk" ]; then
    echo -e "${YELLOW}EB application not initialized. Initializing...${NC}"
    echo ""
    echo "Please answer the following questions:"
    eb init
    echo ""
fi

# Ask user what to do
echo "What would you like to do?"
echo "1) Create new environment"
echo "2) Deploy to existing environment"
echo "3) Set environment variables"
echo "4) View logs"
echo "5) Check status"
echo "6) Open in browser"
echo "7) SSH into instance"
read -p "Enter choice [1-7]: " choice

case $choice in
    1)
        echo ""
        read -p "Enter environment name (e.g., sengp-backend-prod): " env_name
        read -p "Include RDS database? (y/n): " include_rds

        if [ "$include_rds" = "y" ]; then
            read -p "Database username (default: admin): " db_user
            db_user=${db_user:-admin}
            read -sp "Database password: " db_pass
            echo ""

            echo -e "${YELLOW}Creating environment with RDS...${NC}"
            eb create "$env_name" \
                --instance-type t3.small \
                --platform docker \
                --database \
                --database.engine postgres \
                --database.instance db.t3.micro \
                --database.username "$db_user" \
                --database.password "$db_pass"
        else
            echo -e "${YELLOW}Creating environment without RDS...${NC}"
            eb create "$env_name" \
                --instance-type t3.small \
                --platform docker
        fi
        ;;

    2)
        echo ""
        eb list
        echo ""
        read -p "Enter environment name to deploy to: " env_name
        echo -e "${YELLOW}Deploying to $env_name...${NC}"
        eb deploy "$env_name"
        echo -e "${GREEN}✓ Deployment complete${NC}"
        ;;

    3)
        echo ""
        echo "Environment variables can be set in multiple ways:"
        echo ""
        echo "Option 1: Set from env.yaml file"
        echo "  Create env.yaml with your variables and run:"
        echo "  eb setenv \$(cat env.yaml | grep '=' | xargs)"
        echo ""
        echo "Option 2: Set individually"
        echo "  eb setenv VAR1=value1 VAR2=value2"
        echo ""
        echo "Option 3: Use AWS Console"
        echo "  Go to EB Console > Configuration > Software > Environment properties"
        ;;

    4)
        echo ""
        eb logs
        ;;

    5)
        echo ""
        eb status
        echo ""
        eb health
        ;;

    6)
        echo ""
        eb open
        ;;

    7)
        echo ""
        eb ssh
        ;;

    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}Done!${NC}"
