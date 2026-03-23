# EC2 Application Deployment (AWS + Terraform)

## Overview
This project deploys a production-style AWS infrastructure including:
- Custom VPC
- Public subnet
- Internet Gateway
- Route tables
- Security groups
- EC2 instance running a web server

## Architecture
Internet → IGW → Public Subnet → EC2 (Apache Web Server)

## Features
- Fully isolated VPC
- Public subnet with internet access
- Auto-installed web server via user_data
- Dynamic AMI lookup
- Remote state backend (S3 + DynamoDB)

## Usage

### 1. Setup backend
Update backend.tf with your S3 bucket and DynamoDB table.

### 2. Run Terraform
```bash
terraform init
terraform plan
terraform apply