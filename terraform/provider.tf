# In terraform.tf (or providers.tf as per style guide recommendation)
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
