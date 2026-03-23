variable "cidr_block" { type = string }

variable "public_subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}