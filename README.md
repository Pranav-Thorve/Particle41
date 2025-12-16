# SimpleTimeService – Particle41 DevOps Challenge

## Overview

This repository contains a Python-based web service and the Terraform configurations required to deploy it to a Amazon EKS cluster. 

The goal of this project is to:

- Building a minimal web service
- Containerizing it following best practices
- Publishing the container image to a public registry
- Deploying the application to AWS using **Infrastructure as Code (Terraform)**
 

The solution is split into two main parts:
1. **Application + Docker**
2. **Infrastructure + Deployment using Terraform on AWS EKS**


## SimpleTimeService Application

### Description

**SimpleTimeService** is a minimal HTTP web service that returns a JSON response when the root (`/`) endpoint is accessed.

Example response:

```json
{
  "timestamp": "2025-01-01T12:00:00Z",
  "ip": "203.0.113.10"
}
```
- timestamp: Current UTC date and time
- ip: Client IP address

#### Technology Choices
- Language: Python (standard library only)
#### Web Server: http.server
#### Container Runtime: Docker


**Docker Image**
- Container Best Practices
- Runs as a non-root user
- Uses a minimal base image
- Single command to build and run
- No secrets baked into the image



### Build the Image

```shell
cd app
docker build -t <dockerhub-username>/simple-time-service:latest .
```

### Run the Container Locally
```shell
docker run -p 8080:8080 <dockerhub-username>/simple-time-service:latest
```

### Access:

```shell
http://localhost:8080/
```



## Infrastructure with Terraform (AWS)
### Architecture Overview
#### AWS EKS for container orchestration

#### VPC with:

 - 2 public subnets
 - 2 private subnets
 - Worker nodes run in private subnets only
 - Kubernetes Service (LoadBalancer) exposes the application


### Terraform manages all infrastructure


### Prerequisites

#### Install the following tools:

- Terraform  - Reference DOC:- https://developer.hashicorp.com/terraform/downloads
- #### AWS Authentication
  For AWS authentication use any of these methods

1. **AWS access/secret**
    ```json
    provider "aws" {
    region = "us-east-1"
    access_key = "YOUR_ACCESS_KEY"
    secret_key = "YOUR_SECRET_KEY"
    }
    ```


2. **configure aws-cli** 
  - AWS CLI Installation Reference DOC:- https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html


3. **Export credentials in environment variables**
    ```json
    export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
    export AWS_DEFAULT_REGION=us-east-1
    ```

#### Before running Terraform, ensure the following resources already exist in AWS:
- An S3 bucket for storing the Terraform state file
- A DynamoDB table for Terraform state locking

**Note** - update bucket and dynamodb field in backend.tf accodingly


## Deploying the Infrastructure and Application
```bash
# Move into the Terraform directory.
# All Terraform commands must be run from this directory
# because it contains the Terraform configuration files.
cd terraform

# Initialize the Terraform working directory.
# This command:
# - Configures the remote backend (S3 + DynamoDB)
# - Downloads required Terraform providers
# - Prepares Terraform to run plan and apply
terraform init

# Show an execution plan.
# This command:
# - Displays all resources Terraform will create, update, or delete
# - Does NOT make any changes to AWS
# - Is used to review changes before applying them
terraform plan

# Apply the Terraform configuration.
# This command:
# - Creates all AWS infrastructure
# - Deploys the EKS cluster and node group
# - Deploys the application on Kubernetes
# - Creates the public load balancer
# You will be prompted to confirm before Terraform proceeds
terraform apply
```

## Accessing the Application
After deployment, Terraform outputs the load balancer DNS in **simple_time_service_dns**:


```text
simple_time_service_dns = a1b2c3d4e5.elb.amazonaws.com
```

### Test the service:
**Note** :- Wait for 1-2 minutes to Load balancer to become ready to serve

```bash
curl http://<simple_time_service_dns>
```
