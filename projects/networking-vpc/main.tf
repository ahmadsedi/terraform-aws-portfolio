module "vpc" {
  source = "../../modules/vpc"

  cidr_block = "10.0.0.0/16"

  public_subnets = [
    { name = "subnet-1", cidr = "10.0.1.0/24", az = "eu-west-2a" }
  ]
}