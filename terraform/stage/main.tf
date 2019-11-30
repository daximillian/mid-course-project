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

module "webserver_cluster" {
  source = "../global/webserver"

  websrv_remote_state_bucket = "nofar-opsschool-state"
  websrv_remote_state_key    = "stage/terraform.tfstate"
}