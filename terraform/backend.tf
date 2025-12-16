terraform {
  backend "s3" {
    bucket         = "<YOUR-BUCKET-NAME>"
    key            = "simple-time-service/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "<YOUR-DYNAMODB-TABLE>"
    encrypt        = true
  }
}