
# EKS Cluster
# Creates the Amazon EKS control plane
resource "aws_eks_cluster" "particle41-eks" {
  name = var.eks-cluster-name

  # Enable both API-based and aws-auth ConfigMap authentication
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.particle41-cluster.arn

  version  = var.eks-version

  # Networking configuration for the EKS control plane
  vpc_config {
    # Allow private access from within the VPC
    endpoint_private_access = true

    # Allow public access for management and automation
    endpoint_public_access  = true

    subnet_ids = var.subnets
  }

  # Ensure required IAM policy is attached before cluster creation
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

# IAM Role for EKS Control Plane
resource "aws_iam_role" "particle41-cluster" {
  name = "eks-cluster-role"

  # Trust policy allowing EKS service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# IAM Policy Attachment for EKS Cluster
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.particle41-cluster.name
}

# EKS Add-ons
# Core Kubernetes components managed by AWS

# VPC CNI plugin for pod networking
resource "aws_eks_addon" "vpccni" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "vpc-cni"
}

# CoreDNS for internal cluster DNS resolution
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "coredns"
}

# kube-proxy for service networking
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "kube-proxy"
}

# Pod Identity Agent to support IAM roles for pods
resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = aws_eks_cluster.particle41-eks.name 
  addon_name   = "eks-pod-identity-agent"

  # Overwrite conflicts to ensure consistent addon state
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks-ng-role" {
  name = "${var.eks-cluster-name}-ng-role"

  # Trust policy allowing EC2 instances to assume this role
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# IAM Policy Attachments for Node Group

# Required for worker nodes to communicate with EKS
resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-ng-role.name
}

# Required for VPC CNI networking
resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-ng-role.name
}

# Allows nodes to pull images from ECR
resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-ng-role.name
}

# Enables SSM access for node management and debugging
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.eks-ng-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EKS Managed Node Group
resource "aws_eks_node_group" "eks-nodegroup" {
  cluster_name    = aws_eks_cluster.particle41-eks.name
  node_group_name = "${var.eks-cluster-name}-ng"

  node_role_arn   = aws_iam_role.eks-ng-role.arn

  subnet_ids      = var.subnets

  instance_types = [ var.node-instance-type ]
  
  scaling_config {  
    desired_size = var.desired-nodes
    max_size     = var.max-nodes
    min_size     = var.min-nodes
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-ng-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-ng-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-ng-role-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.ssm
  ]
}

# Identifies the IAM principal running Terraform
data "aws_caller_identity" "current" {}

# EKS Access Entry
# Grants Kubernetes access to the IAM principal via AWS API
resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = aws_eks_cluster.particle41-eks.name
  principal_arn = data.aws_caller_identity.current.arn

  type = "STANDARD"

  # Ensure cluster exists before creating access entry
  depends_on = [ aws_eks_cluster.particle41-eks ]
}

# Assigns cluster-admin permissions to the IAM principal
resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = aws_eks_cluster.particle41-eks.name
  principal_arn = data.aws_caller_identity.current.arn

  # AWS-managed cluster admin policy
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  # Apply permissions at the cluster scope
  access_scope {
    type = "cluster"
  }

  depends_on = [ aws_eks_cluster.particle41-eks ]
}
