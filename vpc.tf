resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.prefix}vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "${var.prefix}igw-default"
    }
}

/*
  NAT Instance
*/
resource "aws_security_group" "nat_sg" {
    name = "nat-sg"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["95.223.71.65/32"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "${var.prefix}nat-sg"
    }
}

resource "aws_instance" "nat-instance" {
    ami = "ami-00c1445796bc0a29f" # this is a special ami preconfigured to do NAT
    availability_zone = "${var.availability_zone}"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_sg.id}"]
    subnet_id = "${aws_subnet.public-subnet.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "${var.prefix}nat-instance"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat-instance.id}"
    vpc = true
}

/*
  Public Subnet
*/
resource "aws_subnet" "public-subnet" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "${var.prefix}public-subnet"
    }
}

resource "aws_route_table" "public-subnet-route-table" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "${var.prefix}public-route-table"
    }
}

resource "aws_route_table_association" "public-subnet-route-association" {
    subnet_id = "${aws_subnet.public-subnet.id}"
    route_table_id = "${aws_route_table.public-subnet-route-table.id}"
}

/*
  Private Subnet
*/
resource "aws_subnet" "private-subnet" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "${var.prefix}private-subnet"
    }
}

resource "aws_route_table" "private-subnet-route-table" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat-instance.id}"
    }

    tags {
        Name = "${var.prefix}private-route-table"
    }
}

resource "aws_route_table_association" "tre-playground-private" {
    subnet_id = "${aws_subnet.private-subnet.id}"
    route_table_id = "${aws_route_table.private-subnet-route-table.id}"
}
