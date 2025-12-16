resource "aws_vpc" "particle41-vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "particle41-private-subnet1" {
  vpc_id     = aws_vpc.particle41-vpc.id
  cidr_block = var.privatesubent1_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = var.privatesubent1
  }
}

resource "aws_subnet" "particle41-private-subnet2" {
  vpc_id     = aws_vpc.particle41-vpc.id
  cidr_block = var.privatesubent2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = var.privatesubent2
  }
}

resource "aws_subnet" "particle41-public-subnet1" {
  vpc_id     = aws_vpc.particle41-vpc.id
  cidr_block = var.publicsubent1_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = var.publicsubent1
  }
}

resource "aws_subnet" "particle41-public-subnet2" {
  vpc_id     = aws_vpc.particle41-vpc.id
  cidr_block = var.publicsubent2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = var.publicsubent2
  }
}



resource "aws_internet_gateway" "particle41-igw" {
  vpc_id = aws_vpc.particle41-vpc.id

  tags = {
    Name = var.igw-name
  }
}


resource "aws_eip" "natip" {
  domain   = "vpc"
}


resource "aws_nat_gateway" "particle41-nat" {
  allocation_id = aws_eip.natip.id
  subnet_id     = aws_subnet.particle41-public-subnet1.id

  tags = {
    Name = var.nat-name
  }

  depends_on = [aws_internet_gateway.particle41-igw]
}

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

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.particle41-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.particle41-nat.id
  }


  tags = {
    Name = var.private-rt
  }
}


resource "aws_security_group" "eks-node-sg" {
  name        = var.eks-node-sg
  vpc_id      = aws_vpc.particle41-vpc.id

  tags = {
    Name = var.eks-node-sg
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.eks-node-sg.id
  cidr_ipv4         = aws_vpc.particle41-vpc.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks-node-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


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

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.s3"
  route_table_ids = [ aws_route_table.private-rt.id ]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.eks-node-sg.id ]
  subnet_ids = [ aws_subnet.particle41-private-subnet1.id, aws_subnet.particle41-private-subnet2.id ]
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.eks-node-sg.id ]
  subnet_ids = [ aws_subnet.particle41-private-subnet1.id, aws_subnet.particle41-private-subnet2.id ]
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.eks-node-sg.id ]
  subnet_ids = [ aws_subnet.particle41-private-subnet1.id, aws_subnet.particle41-private-subnet2.id ]
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.sts"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.eks-node-sg.id ]
  subnet_ids = [ aws_subnet.particle41-private-subnet1.id, aws_subnet.particle41-private-subnet2.id ]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id       = aws_vpc.particle41-vpc.id
  service_name = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type = "Interface"
  security_group_ids = [ aws_security_group.eks-node-sg.id ]
  subnet_ids = [ aws_subnet.particle41-private-subnet1.id, aws_subnet.particle41-private-subnet2.id ]
}
