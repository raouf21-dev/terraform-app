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
  cidr_block           = "10.0.0.0/16"
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

resource "aws_route_table" "open_web_ui" {
  vpc_id = aws_vpc.open_web_ui.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.open_web_ui.id
  }
}

resource "aws_route_table_association" "open_web_ui" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.open_web_ui.id
}

resource "aws_security_group" "ssh" {
  vpc_id = aws_vpc.open_web_ui.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "open_web_ui" {
  key_name   = "open_wevb_ui"
  public_key = file("~/.ssh/id_ed25519.pub")

}

resource "aws_spot_instance_request" "cheap_worker" {
  ami = data.aws_ami.debian.id
  #   spot_price    = "0.03"
  instance_type = "t4g.micro"

  associate_public_ip_address = true
  key_name                    = aws_key_pair.open_web_ui.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  subnet_id                   = aws_subnet.subnet.id
  wait_for_fulfillment        = true

}

