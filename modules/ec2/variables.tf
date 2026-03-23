variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "tags" {
  type    = map(string)
  default = {}
}