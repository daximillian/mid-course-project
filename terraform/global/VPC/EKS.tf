data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

locals {
  cluster_name = "opsSchool-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = aws_subnet.private.*.id

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = "${aws_vpc.terra_vpc.id}"

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.micro"
      # additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2 
      asg_max_size                  = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    }
    # }, when there's more than one worker group, delete the previous } and replace it with this.
    # {
    #   name                          = "worker-group-2"
    #   instance_type                 = "t2.medium"
    #   additional_userdata           = "echo foo bar"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    #   asg_desired_capacity          = 1
    # },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles  = [
    {
        rolearn  = aws_iam_role.eks-kubectl.arn
        username = "ubuntu"
        groups   = ["system:masters"]
    }
  ]
  
  # map_users                            = var.map_users
  # map_accounts                         = var.map_accounts
}
