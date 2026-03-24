include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../projects/eks-cluster"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name = dependency.eks.outputs.cluster_name
}