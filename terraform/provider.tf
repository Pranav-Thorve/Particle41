
terraform {
  required_providers {
    # Declares the AWS provider, its source, and version constraints
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# The provider block configures the "aws" provider
provider "aws" {
  region = "us-east-1"
}




data "aws_eks_cluster" "eks" {
  name = var.eks-cluster-name
  depends_on = [ module.eks ]
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks-cluster-name
  depends_on = [ module.eks ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.eks.token
}