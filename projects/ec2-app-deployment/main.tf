module "ec2" {
  source        = "../../modules/ec2"
  ami           = "ami-123456"
  instance_type = "t3.micro"
  subnet_id     = "subnet-123"
}