include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name = "dev-eks-cluster"

  subnet_ids = dependency.vpc.outputs.public_subnet_ids
}