resource "aws_s3_bucket" "websrv_log" {
  bucket = "nofar-websrv-log"

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Webserver access logs"
  }
}


resource "aws_iam_role" "websrv_role" {
  name = "websrv_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

resource "aws_iam_instance_profile" "websrv_profile" {
  name = "websrv_profile"
  role = "${aws_iam_role.websrv_role.name}"
}

resource "aws_iam_role_policy" "websrv_policy" {
  name = "websrv_policy"
  role = "${aws_iam_role.websrv_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "*"
            ]
    }
  ]
}
EOF
}

