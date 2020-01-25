data "aws_ami" "ubuntu" {
most_recent = true

  filter {
    name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
 }

  filter {
   name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "ubuntu-nodes" {
 
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = aws_key_pair.VPC-demo-key.key_name
  iam_instance_profile = aws_iam_instance_profile.eks-kubectl.name
  subnet_id = aws_subnet.public.0.id
  associate_public_ip_address = true
  user_data = file("install_python.sh")

  tags = {
    Name = "Ubuntu Node"
  }
}

resource "aws_instance" "server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = aws_key_pair.VPC-demo-key.key_name
  subnet_id = aws_subnet.public.1.id
  associate_public_ip_address = true
  user_data = file("install_python.sh")

  tags = {
    Name = "Server"
  }
}

data "template_file" "dev_hosts" {
  template = "${file("dev_hosts.cfg")}"
 
  depends_on = [
    aws_instance.server,
    aws_instance.ubuntu-nodes
    
  ]
  vars = {
    servers = aws_instance.server.public_ip
    ubuntu_nodes = aws_instance.ubuntu-nodes.public_ip
  }
  # vars = {
  #   servers = "${join("\n", [for instance in aws_instance.server : instance.public_ip] )}"
  #   ubuntu_nodes = "${join("\n", [for instance in aws_instance.ubuntu-nodes : instance.public_ip] )}"
  #   # redhat_nodes = "${join("\n", [for instance in aws_instance.redhat-nodes : instance.public_ip] )}"
    
  #   # servers = "${join("\n", module.servers.server_ip)}"
  # }
}

resource "null_resource" "host_file" {
  triggers = {
    template_rendered = data.template_file.dev_hosts.rendered
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.dev_hosts.rendered}\" > hosts.INI"
  }
}


