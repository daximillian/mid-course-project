resource "aws_instance" "webservers" {
  count = "${length(var.subnets_cidr_public)}" 
  ami = "${var.webservers_ami}"
  availability_zone = "${element(var.azs,count.index)}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.webservers.id}"]
  subnet_id = "${element(aws_subnet.public.*.id,count.index)}"
  key_name   = "${aws_key_pair.VPC-demo-key.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.websrv_profile.name}"
  associate_public_ip_address = true
  user_data = file("${path.module}/install-nginx.sh")

   connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = "${tls_private_key.VPC-demo-key.private_key_pem}"
  }

  provisioner "file" {
    content = <<EOF
[default]
access_key =
secret_key =
security_token =
EOF
    destination = "/home/ubuntu/.s3cfg"
  }

  provisioner "file" {
    content = <<EOF
/var/log/nginx/access.log {
    hourly
    rotate 240
    missingok
    compress
    sharedscripts
    postrotate
    endscript
    lastaction
        INSTANCE_ID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id`
        sudo s3cmd sync --config=/home/ubuntu/.s3cfg /var/log/nginx/access.* s3://${aws_s3_bucket.websrv_log.id}/nginx/$INSTANCE_ID/
    endscript
}

EOF

    destination = "/home/ubuntu/nginx"
  }

    tags = {
    Name = "Webserver-${count.index}"
  }
}



resource "aws_instance" "dbservers" {
  count = "${length(var.subnets_cidr_public)}" 
  ami = "${var.dbservers_ami}"
  availability_zone = "${element(var.azs,count.index)}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.dbservers.id}"]
  subnet_id = "${element(aws_subnet.private.*.id,count.index)}"
  key_name      = "${aws_key_pair.VPC-demo-key.key_name}"

  tags = {
    Name = "Dbserver-${count.index}"
  }
}


output "webservers_public_address" {
    value = aws_instance.webservers.*.public_ip
}

output "dbservers_private_addresses" {
    value = aws_instance.dbservers.*.private_ip
}