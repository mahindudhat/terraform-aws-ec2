provider "aws" {
  region     = "${var.region}"
  access_key = "${var.accesskey}"
  secret_key = = "${var.secretkey}"
}

# Create a VPC
resource "aws_vpc" "main" {     #You also can use your pre build configured network (AWS- VPC) with subnet, security group, internet gateway and route table
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

# Add firewall rules
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instance in public subnet 
resource "aws_instance" "web" {
  ami           = "${var.amiID}"  # Replace with latest Amazon machine image
  instance_type = "t2.micro"
  key_name        = "${var.keyname}"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.name]
  
  tags = {
    Name = "WebServer"
  }
}

# Install apche2 webserver
provisioner "remote-exec" {
    inline                  = [
      "sudo apt-get update -y",  
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

# Create a database in private subnet
resource "aws_db_instance" "db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  user                 = "${var.username}"
  pass                 = "${var.password}"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}