variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}
variable "prefix" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "ap-southeast-2"
}

variable "availability_zone" {
  description = "Availability zone"
  default = "ap-southeast-2a"  
}

variable "amis" {
    description = "AMIs by region"
    default = {
        ap-southeast-2 = "ami-67589505" # RHEL 7.5
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "192.168.0.0/23"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "192.168.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "192.168.1.0/24"
}
