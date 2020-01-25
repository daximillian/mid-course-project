resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "Allow SSH inbound traffic from VPC"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
    # HTTP access from anywhere
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "jenkins-sg" {
 name        = "jenkins-sg"
 description = "security group for jenkins nodes"
 vpc_id      = aws_vpc.terra_vpc.id
  egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ingress {
   from_port   = 8
   to_port     = 0
   protocol    = "icmp"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

# Create an IAM role for eks kubectl
resource "aws_iam_role" "eks-kubectl" {
  name               = "opsschool-eks-kubectl"
  assume_role_policy = file("policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "eks-kubectl" {
  name        = "opsschool-eks-kubectl"
  description = "Allows unubtu node to run kubectl."
  policy      = file("policies/describe-eks.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "eks-kubectl" {
  name       = "opsschool-eks-kubectl"
  roles      = [aws_iam_role.eks-kubectl.name]
  policy_arn = aws_iam_policy.eks-kubectl.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "eks-kubectl" {
  name  = "opsschool-eks-kubectl"
  role = aws_iam_role.eks-kubectl.name
}