terraform {
  backend "s3" {
    bucket         = "nofar-opsschool-state"
    key            = "stage/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"

}