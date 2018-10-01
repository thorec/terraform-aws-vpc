/*
  SSH Servers
*/
resource "aws_security_group" "ssh_sg" {
  name = "ssh-sg"
  description = "Allow incoming SSH connections."

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "79.233.116.46/32",   # Recker Ahlen, Pfitznerweg 8
      "95.223.71.65/32",    # Recker Ahlen, Lortzingweg 10
      "158.140.224.246/32", # Recker Wellington
      "158.140.232.61/32",  # IQA Wellington
      "172.31.2.10/32",     # unknown
      "172.31.12.125/32",   # unknown
      "172.31.13.138/32"    # unknown
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.prefix}ssh-sg"
  }
}

resource "aws_instance" "bastion" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "${var.availability_zone}"
  instance_type = "t2.micro"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh_sg.id}"]
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address = true
  source_dest_check = false

  tags {
    Name = "${var.prefix}bastion-host"
  }
}

resource "aws_security_group" "wildfly_sg" {
  name = "${var.prefix}wildfly-sg"
  description = "Allow incoming connections to Wildfly server."

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "79.233.116.46/32",   # Recker Ahlen, Pfitznerweg 8
      "95.223.71.65/32",    # Recker Ahlen, Lortzingweg 10
      "158.140.224.246/32", # Recker Wellington
      "158.140.232.61/32"   # IQA Wellington
    ]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.prefix}wildfly-sg"
  }
}

resource "aws_security_group" "virtualize_sg" {
  name = "${var.prefix}virtualize-sg"
  description = "Allow incoming connections to Wildfly server."

  ingress {
    from_port = 9080
    to_port = 9080
    protocol = "tcp"
    cidr_blocks = [
      "79.233.116.46/32",   # Recker Ahlen, Pfitznerweg 8
      "95.223.71.65/32",    # Recker Ahlen, Lortzingweg 10
      "158.140.224.246/32", # Recker Wellington
      "158.140.232.61/32"   # IQA Wellington
    ]
  }
  ingress {
    from_port = 9443
    to_port = 9443
    protocol = "tcp"
    cidr_blocks = [
      "79.233.116.46/32",   # Recker Ahlen, Pfitznerweg 8
      "95.223.71.65/32",    # Recker Ahlen, Lortzingweg 10
      "158.140.224.246/32", # Recker Wellington
      "158.140.232.61/32"   # IQA Wellington
    ]
  }
  ingress {
    from_port = 9616
    to_port = 9619
    protocol = "tcp"
    cidr_blocks = [
      "79.233.116.46/32",   # Recker Ahlen, Pfitznerweg 8
      "95.223.71.65/32",    # Recker Ahlen, Lortzingweg 10
      "158.140.224.246/32", # Recker Wellington
      "158.140.232.61/32"   # IQA Wellington
    ]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "${var.prefix}virtualize-sg"
  }
}
