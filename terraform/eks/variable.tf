variable "eks-cluster-name" {
  type = string
}

variable "eks-version" {
  type = string
}

variable "subnets" {
  type = list(string)
}
