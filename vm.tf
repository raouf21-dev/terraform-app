# Request a spot instance at $0.03
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-11-arm64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "open_web_ui" {
  cidr_block           = "10.1.0.0/12"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.open_web_ui.cidr_block, 3, 1)
  vpc_id            = aws_vpc.open_web_ui.id
  availability_zone = "eu-west-3a"

}

resource "aws_internet_gateway" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id
}

resource "aws_spot_instance_request" "cheap_worker" {
  ami = data.aws_ami.debian.id
  #   spot_price    = "0.03"
  instance_type = "t4g.micro"

  tags = {
    Name = "CheapWorker"
  }
}
