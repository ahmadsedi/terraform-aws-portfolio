terraform {
  backend "s3" {
    bucket         = "terraform-aws-portfolio-remote-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}