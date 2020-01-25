resource "tls_private_key" "VPC-demo-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "VPC-demo-key" {
  key_name   = "VPC-demo-key"
  public_key = tls_private_key.VPC-demo-key.public_key_openssh
}

resource "local_file" "VPC-demo-key" {
  sensitive_content  = tls_private_key.VPC-demo-key.private_key_pem
  filename           = "VPC-demo-key.pem"
}