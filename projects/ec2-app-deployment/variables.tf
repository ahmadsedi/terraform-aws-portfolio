variable "region" { type = string }
variable "project_name" { type = string }
variable "environment" { type = string }

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "tags" {
  type    = map(string)
  default = {}
}