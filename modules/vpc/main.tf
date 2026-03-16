locals {
  common_tags = {
    CreatedBy   = "Aasrith"
    Environment = "dev"
    Project     = "week4"
    Purpose     = "Training Plan"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-1"
  })
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-2"
  })
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-1"
  })
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-private-2"
  })
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Rule for ALB: Allow public HTTP traffic
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  # Rule for EC2: Allow SSH from within the SG (for EICE)
  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    self      = true
    description = "Allow SSH from EICE in same SG"
  }
  
  # Rule for EC2: Allow HTTP from within the SG (for ALB to Target Group)
  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    self      = true
    description = "Allow HTTP from ALB in same SG"
  }

  # Egress: Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-default-sg"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-public-rt"
  })
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = aws_subnet.private1.id
  # Using the default SG to avoid CreateSecurityGroup error
  security_group_ids = [aws_default_security_group.default.id]

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-eice"
  })
}
