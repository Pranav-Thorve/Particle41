variable "vpc_cidr_block" {
  type = string
  description = "provide cidr for vpc"
}


variable "vpc_name" {
  type = string
  description = "provide name for vpc"
}

variable "privatesubent1" {
  type = string
  description = "private subnet 1 name"
}

variable "privatesubent2" {
  type = string
  description = "private subnet 2 name"
}

variable "publicsubent1" {
  type = string
  description = "public subnet 1 name"
}

variable "publicsubent2" {
  type = string
  description = "public subnet 2 name"
}

variable "privatesubent1_cidr" {
  type = string
  description = "private subnet 1 cidr"
}

variable "privatesubent2_cidr" {
  type = string
  description = "private subnet 2 cidr"
}

variable "publicsubent1_cidr" {
  type = string
  description = "public subnet 1 cidr"
}

variable "publicsubent2_cidr" {
  type = string
  description = "public subnet 2 cidr"
}

variable "igw-name" {
  type = string
  description = "name for igq"
}

variable "nat-name" {
  type = string
  description = "name for nat"
}

variable "public-rt" {
  type = string
  description = "name for public rt"
}

variable "private-rt" {
  type = string
  description = "name for private rt"
}

variable "eks-node-sg" {
  type = string
  description = "nodegroup-sg name"
}