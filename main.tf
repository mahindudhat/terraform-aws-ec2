provider "aws" {
  region     = "${var.region}"
  access_key = "${var.accesskey}"
  secret_key = "${var.secretkey}"
}

resource "aws_instance" "myfirst" {
  ami             = "${var.amiID}"
  instance_type   = "t2.micro"
  key_name        = "${var.keyname}"
  security_groups = ["${aws_security_group.allow_all.name}"]

provisioner "remote-exec" {
    inline                  = [
        "sudo apt-get install apache2 -y"
    ]

    connection {
        type                = "ssh"
        user                = "ubuntu"
        private_key         = file("./Nagios.pem")
        host                = aws_instance.myfirst.public_ip
    }
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpcID}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

