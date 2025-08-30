# SECURITY GROUP
resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-openvpn-server-sg"
  description = "Allow inbound traffic to OpenVPN server"
  vpc_id      = var.vpc_id

  ingress {
    description = "Access UDP 1194 anywhere"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access HTTPS anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access 943 anywhere"
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Access 945 anywhere"
    from_port   = 945
    to_port     = 945
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ips
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-openvpn-server-sg" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))
}

# INSTANCE 
resource "aws_key_pair" "this" {
  key_name   = "${var.project}-${var.environment}-openvpn-server-key"
  public_key = var.public_key
  tags       = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-openvpn-server-key" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"
  tags     = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-openvpn-server-eip" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))
}


resource "aws_instance" "this" {
  ami                         = var.marketplace_access_server_ami
  associate_public_ip_address = true
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = var.subnet_id

  vpc_security_group_ids = [aws_security_group.this.id]
  volume_tags            = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))
  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = false
    encrypted             = true
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-openvpn-server" }), tomap({ "${var.project}:TechnicalFunction" = "compute" }))
}
