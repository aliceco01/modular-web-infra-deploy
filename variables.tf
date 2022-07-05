# VPC Prefix
variable "vpc_prefix" {
  description = "VPC Prefix"
}

# Route Tables

variable "public_route_table_cidr" {
    description = "Public Route Table"
}

variable "private_route_table_cidr" {
    description = "Private Route Table"
}

# Subnets Prefix

variable "public_subnet-1_cidr" {
    description = "Public Subnet Prefix"
}

variable "private_subnet-1_cidr" {
    description = "Private Subnet Prefix"
}

variable "public_subnet-2_cidr" {
    description = "Public Subnet Prefix"
}

variable "private_subnet-2_cidr" {
    description = "Private Subnet Prefix"
}

# Availability Zones

variable "availability_zone-1" {
    description = "First Availability Zone"
}

variable "availability_zone-2" {
    description = "Second Availability Zone"
}

# AMI

variable "ami" {
    description = "Amazon Linux 2 AMI to Use"
}
