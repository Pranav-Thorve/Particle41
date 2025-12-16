variable "eks-cluster-name" {
  type = string
}

variable "eks-version" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "node-instance-type" {
  type = string
}

variable "desired-nodes" {
  type = number
}

variable "max-nodes" {
  type = number
}

variable "min-nodes" {
  type = number
}