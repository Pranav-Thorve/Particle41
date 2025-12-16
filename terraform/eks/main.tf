resource "aws_eks_cluster" "particle41-eks" {
  name = var.eks-cluster-name

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  role_arn = aws_iam_role.particle41-cluster.arn
  version  = var.eks-version

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = var.subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "particle41-cluster" {
  name = "eks-cluster-role"
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

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.particle41-cluster.name
}

resource "aws_eks_addon" "vpccni" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "vpc-cni"
}


resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "coredns"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.particle41-eks.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "eks_pod_identity_agent" {
  cluster_name = aws_eks_cluster.particle41-eks.name # Reference to your existing EKS cluster resource
  addon_name   = "eks-pod-identity-agent"
  # Optional: Specify the version, or let AWS manage it
  # addon_version = "v1.x.x-eksbuild.x"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_iam_role" "eks-ng-role" {
  name = "${var.eks-cluster-name}-ng-role"

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

resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-ng-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-ng-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ng-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-ng-role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.eks-ng-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}




resource "aws_eks_node_group" "eks-nodegroup" {
  cluster_name    = aws_eks_cluster.particle41-eks.name
  node_group_name = "${var.eks-cluster-name}-ng"
  node_role_arn   = aws_iam_role.eks-ng-role.arn
  subnet_ids      = var.subnets
  instance_types = [ "t3.medium" ]
  
  scaling_config {  
    desired_size = 1
    max_size     = 2
    min_size     = 1
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