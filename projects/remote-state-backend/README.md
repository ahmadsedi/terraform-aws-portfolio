# Terraform Remote State Backend (AWS)

## Overview
This project provisions a secure, production-grade Terraform remote state backend using AWS.

## Architecture
- S3 bucket for storing Terraform state
- DynamoDB table for state locking
- Server-side encryption enabled
- Versioning enabled
- Public access blocked

## Features
- Secure by default
- Supports multiple environments
- Prevents concurrent state corruption
- Fully tagged resources

## Usage

### 1. Initialize
```bash
terraform init