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

# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = 3
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    config = <<EOF
     "node_name": "opsschool-consul-server-${count.index+1}",
     "server": true,
     "bootstrap_expect": 3,
     "ui": true,
     "client_addr": "0.0.0.0"
    EOF
  }
}

data "template_file" "consul_jenkins_master" {
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
      consul_version = var.consul_version
      config = <<EOF
       "node_name": "opsschool-jenkins-master",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}

# Create the user-data for the Consul agent
data "template_cloudinit_config" "consul_jenkins_master" {
  part {
    content = data.template_file.consul_jenkins_master.rendered
  }
  part {
    content = file("${path.module}/templates/jenkins_master.sh.tpl")
  }
}


data "template_file" "consul_jenkins_node" {
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
      consul_version = var.consul_version
      config = <<EOF
       "node_name": "opsschool-jenkins-node",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}

# Create the user-data for the Consul agent
data "template_cloudinit_config" "consul_jenkins_node" {
  part {
    content = file("${path.module}/templates/install_python.sh.tpl")
  }
  
  part {
    content = data.template_file.consul_jenkins_node.rendered

  }
  part {
    content = file("${path.module}/templates/jenkins_node.sh.tpl")
  }
}

resource "aws_instance" "ubuntu-nodes" {
 
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id, aws_security_group.opsschool_consul.id]
  key_name               = aws_key_pair.VPC-demo-key.key_name
  iam_instance_profile = aws_iam_instance_profile.eks-kubectl.name
  subnet_id = aws_subnet.public.0.id
  associate_public_ip_address = true
  user_data = data.template_cloudinit_config.consul_jenkins_node.rendered

  tags = {
    Name = "Jenkins Ubuntu Node"
  }
}

resource "aws_instance" "jenkins_server" {

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.jenkins-sg.id, aws_security_group.opsschool_consul.id]
  key_name               = aws_key_pair.VPC-demo-key.key_name
  iam_instance_profile = aws_iam_instance_profile.consul-join.name
  subnet_id = aws_subnet.public.1.id
  associate_public_ip_address = true
  user_data = data.template_cloudinit_config.consul_jenkins_master.rendered

  tags = {
    Name = "Jenkins Server"
  }
}


# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count = 3

  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.VPC-demo-key.key_name
  subnet_id = element(aws_subnet.private.*.id, count.index)

  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [aws_security_group.opsschool_consul.id]
  depends_on = [aws_nat_gateway.nat]

  tags = {
    Name = "consul-server-${count.index+1}"
    consul_server = "true"
  }

  user_data = element(data.template_file.consul_server.*.rendered, count.index)
}


data "template_file" "dev_hosts" {
  template = "${file("dev_hosts.cfg")}"
 
  depends_on = [
    aws_instance.jenkins_server,
    aws_instance.ubuntu-nodes
    
  ]
  vars = {
    servers = aws_instance.jenkins_server.public_ip
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


