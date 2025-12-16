
# VPC
# Main network boundary for the project
resource "aws_vpc" "particle41-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}

# Private Subnets
# Used for EKS worker nodes and internal services
resource "aws_subnet" "particle41-private-subnet1" {
  vpc_id            = aws_vpc.particle41-vpc.id
  cidr_block        = var.privatesubent1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = var.privatesubent1
  }
}

resource "aws_subnet" "particle41-private-subnet2" {
  vpc_id            = aws_vpc.particle41-vpc.id
  cidr_block        = var.privatesubent2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = var.privatesubent2
  }
}

# Public Subnets
# Used for Internet-facing resources (NAT, Load Balancer)
resource "aws_subnet" "particle41-public-subnet1" {
  vpc_id            = aws_vpc.particle41-vpc.id
  cidr_block        = var.publicsubent1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = var.publicsubent1
  }
}

resource "aws_subnet" "particle41-public-subnet2" {
  vpc_id            = aws_vpc.particle41-vpc.id
  cidr_block        = var.publicsubent2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = var.publicsubent2
  }
}

# Internet Gateway
# Enables outbound internet access for public subnets
resource "aws_internet_gateway" "particle41-igw" {
  vpc_id = aws_vpc.particle41-vpc.id

  tags = {
    Name = var.igw-name
  }
}

# NAT Gateway
# Allows private subnets to access the internet securely

# Elastic IP for NAT Gateway
resource "aws_eip" "natip" {
  domain = "vpc"
}

# NAT Gateway placed in a public subnet
resource "aws_nat_gateway" "particle41-nat" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.particle41-public-subnet1.id

  tags = {
    Name = var.nat-name
  }

  # Ensure IGW exists before creating NAT
  depends_on = [aws_internet_gateway.particle41-igw]
}

# Route Tables

# Public Route Table
# Routes internet-bound traffic via IGW
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.particle41-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.particle41-igw.id
  }

  tags = {
    Name = var.public-rt
  }
}

# Private Route Table
# Routes outbound traffic via NAT Gateway
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.particle41-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.particle41-nat.id
  }

  tags = {
    Name = var.private-rt
  }
}

# Route Table Associations
# Associate subnets with correct route tables
resource "aws_route_table_association" "public1-rt-association" {
  subnet_id      = aws_subnet.particle41-public-subnet1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public2-rt-association" {
  subnet_id      = aws_subnet.particle41-public-subnet2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private1-rt-association" {
  subnet_id      = aws_subnet.particle41-private-subnet1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private2-rt-association" {
  subnet_id      = aws_subnet.particle41-private-subnet2.id
  route_table_id = aws_route_table.private-rt.id
}

# Security Group for EKS Nodes & Endpoints
resource "aws_security_group" "eks-node-sg" {
  name   = var.eks-node-sg
  vpc_id = aws_vpc.particle41-vpc.id

  tags = {
    Name = var.eks-node-sg
  }
}

# Allow HTTPS traffic within VPC (EKS control plane, endpoints)
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.eks-node-sg.id
  cidr_ipv4         = aws_vpc.particle41-vpc.cidr_block
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# VPC Endpoints
# Enable private connectivity to AWS services

# S3 Gateway Endpoint for private subnets
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.particle41-vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  route_table_ids   = [aws_route_table.private-rt.id]
}

# Interface Endpoint for ECR API
resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.particle41-vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.eks-node-sg.id]
  subnet_ids          = [
    aws_subnet.particle41-private-subnet1.id,
    aws_subnet.particle41-private-subnet2.id
  ]
}

# Interface Endpoint for ECR Docker registry
resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.particle41-vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.eks-node-sg.id]
  subnet_ids          = [
    aws_subnet.particle41-private-subnet1.id,
    aws_subnet.particle41-private-subnet2.id
  ]
}

# Interface Endpoint for EC2 API
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.particle41-vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.eks-node-sg.id]
  subnet_ids          = [
    aws_subnet.particle41-private-subnet1.id,
    aws_subnet.particle41-private-subnet2.id
  ]
}

# Interface Endpoint for STS
resource "aws_vpc_endpoint" "sts" {
  vpc_id              = aws_vpc.particle41-vpc.id
  service_name        = "com.amazonaws.us-east-1.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.eks-node-sg.id]
  subnet_ids          = [
    aws_subnet.particle41-private-subnet1.id,
    aws_subnet.particle41-private-subnet2.id
  ]
}

# Interface Endpoint for SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.particle41-vpc.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  security_group_ids = [aws_security_group.eks-node-sg.id]
  subnet_ids          = [
    aws_subnet.particle41-private-subnet1.id,
    aws_subnet.particle41-private-subnet2.id
  ]
}
