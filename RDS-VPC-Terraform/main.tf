#Provider Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

   required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA6GBBA2WKGDKWHUMW"
  secret_key = "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"
}

#VPC Configuration
resource "aws_vpc" "my-vpc" {
  cidr_block = "178.52.0.0/16"
}

#Subnet Configuration
resource "aws_subnet" "Ssubnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "178.52.0.0/24"
  availability_zone = "ap-south-1a"
}

#Security group Configuration
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#RDS Instance Configuration
resource "aws_db_instance" "my-db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  identifier             = "my-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db-subnet.name
}



# Create a DB subnet group
resource "aws_db_subnet_group" "db-subnet" {
  name       = "example-db-subnet-group"
  subnet_ids = [aws_subnet.Ssubnet.id]
}
