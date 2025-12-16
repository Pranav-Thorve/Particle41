module "vpc" {
  source = "./vpc"
  igw-name = var.igw-name
  nat-name = var.nat-name
  private-rt = var.private-rt
  privatesubent1 = var.privatesubent1
  privatesubent1_cidr = var.privatesubent1_cidr
  privatesubent2 = var.privatesubent2
  privatesubent2_cidr = var.privatesubent2_cidr
  publicsubent1 = var.publicsubent1
  publicsubent1_cidr = var.publicsubent1_cidr
  publicsubent2 = var.publicsubent1
  publicsubent2_cidr = var.publicsubent2_cidr
  public-rt = var.public-rt
  vpc_cidr_block = var.vpc_cidr_block
  vpc_name = var.vpc_name
  eks-node-sg = var.eks-node-sg
}

module "eks" {
  source = "./eks"
  eks-cluster-name = var.eks-cluster-name
  eks-version = var.eks-version
  subnets = [module.vpc.private_subnet_id1, module.vpc.private_subnet_id2]
  node-instance-type = var.node-instance-type
  desired-nodes = var.desired-nodes
  max-nodes = var.max-nodes
  min-nodes = var.min-nodes
}

module "app" {
  source = "./simpletimeservice"
  eks-image = var.eks-image
  eks-cluster-name = var.eks-cluster-name
  k8s-label = var.k8s-label
}