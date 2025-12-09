variable "project_name" {
  description = "prefix for the name tags of VPC resources"
  type = string
}

variable "vpc_cidr" {
  description = "CIDR for the vpc"
  type = string
  default = "10.0.0.0/16"
}

variable "azs" {
  description = "Avialability zones to use"
  type = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}
