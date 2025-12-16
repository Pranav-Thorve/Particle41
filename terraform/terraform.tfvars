# VPC Configuration

# CIDR block for the main VPC
vpc_cidr_block = "10.20.0.0/16"

# Name tag for the VPC
vpc_name = "particle41-vpc"

# Internet Gateway & NAT Gateway

# Name for the Internet Gateway
igw-name = "particle41-igw"

# Name for the NAT Gateway
nat-name = "particle41-nat"

# Route Tables

# Name for the private route table (used by private subnets)
private-rt = "particle41-pvt-rt"

# Name for the public route table (used by public subnets)
public-rt = "particle41-public-rt"

# Private Subnets

# Name for private subnet in first AZ
privatesubent1 = "particle41-pvt-1"

# CIDR block for private subnet in first AZ
privatesubent1_cidr = "10.20.1.0/24"

# Name for private subnet in second AZ
privatesubent2 = "particle41-pvt-2"

# CIDR block for private subnet in second AZ
privatesubent2_cidr = "10.20.2.0/24"

# Public Subnets

# Name for public subnet in first AZ
publicsubent1 = "particle41-public-1"

# CIDR block for public subnet in first AZ
publicsubent1_cidr = "10.20.3.0/24"

# Name for public subnet in second AZ
publicsubent2 = "particle41-public-2"

# CIDR block for public subnet in second AZ
publicsubent2_cidr = "10.20.4.0/24"

# EKS Cluster Configuration

# Name of the EKS cluster
eks-cluster-name = "particle41-prod"

# Kubernetes version for the EKS cluster
eks-version = "1.34"

# EKS Node Group Configuration

# Security group name for EKS worker nodes
eks-node-sg = "eks-nodegroup-sg"

# EC2 instance type for worker nodes
node-instance-type = "t3.medium"

# Desired number of worker nodes
desired-nodes = 1

# Maximum number of worker nodes
max-nodes = 2

# Minimum number of worker nodes
min-nodes = 1

# Application Configuration

# Docker image for the SimpleTimeService application
eks-image = "docops27/simpletimeservice:latest"

# Kubernetes label used for Deployment and Service
k8s-label = "simple-time-service"
