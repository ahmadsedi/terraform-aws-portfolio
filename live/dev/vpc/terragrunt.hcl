include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vpc"
}

inputs = {
  cidr_block = "10.0.0.0/16"

  public_subnets = [
    { name = "public-1", cidr = "10.0.1.0/24", az = "eu-west-2a" },
    { name = "public-2", cidr = "10.0.2.0/24", az = "eu-west-2b" }
  ]

  tags = {
    Environment = "dev"
    Project     = "tf-portfolio"
  }
}