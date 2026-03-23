resource "aws_vpc" "this" {
  cidr_block = var.cidr_block
  tags       = var.tags
}

resource "aws_subnet" "public" {
  for_each = { for s in var.public_subnets : s.name => s }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = var.tags
}