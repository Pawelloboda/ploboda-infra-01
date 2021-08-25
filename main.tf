terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}


resource "aws_subnet" "main" {
  vpc_id     = "vpc-0eaabe96d9ecc14c3"
  cidr_block = "10.0.0.0/28"
  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "backend" {
  vpc_id     = "vpc-0eaabe96d9ecc14c3"
  cidr_block = "10.0.0.16/28"
  tags = {
    Name = "Backend"
  }
}

resource "aws_subnet" "backend2" {
  vpc_id     = "vpc-0eaabe96d9ecc14c3"
  cidr_block = "10.0.0.32/28"
  tags = {
    Name = "Backend2"
  }
}


resource "aws_instance" "app_server" {
  ami           = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_www.id]
  tags = {
    Name = "nginx front"
  }
  user_data = <<EOF
#!/bin/sh
sudo apt-get update
sudo apt-get install -y nginx
EOF
}
###
resource "aws_db_parameter_group" "default" {
  name   = "rds-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [ aws_subnet.backend.id , aws_subnet.backend2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  identifier           = "mydb"
  name                 = "mydb"
  username             = "root"
  password             = "bardzo_trudne_haslo_do_db.1"
  parameter_group_name = aws_db_parameter_group.default.id
  db_subnet_group_name = aws_db_subnet_group.default.id
  vpc_security_group_ids = [ aws_security_group.allow_mysql.id ]
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az             = false
}

resource "aws_security_group" "allow_mysql" {
  name        = "allow_mysql"
  description = "Allow MYSQL traffic"
  vpc_id      = "vpc-0eaabe96d9ecc14c3"
  ingress = [
    {
      description      = "MYSQL in bound"
      from_port        = 3306  
      to_port          = 3306 # default mysql port 3306, but i use custom port
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"] # acces for all vpc-net but [] range for SG
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    }
  ]

  egress = [
    {
      description      = "MYSQL out bound"
      from_port        = 3306 
      to_port          = 3306 
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    }
  ]
  tags = {
    Name = "allow_mysql"
  }
}

resource "aws_security_group" "allow_www" {
  name        = "allow_www"
  description = "Allow WWW traffic"
  vpc_id      = "vpc-0eaabe96d9ecc14c3"
  ingress = [
    {
      description      = "80 in bound"
      from_port        = 6080 
      to_port          = 6080 # default www port 80, but i use custom port
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"] 
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true 
    }
  ]
egress = [
    {
      description      = "80 out bound"
      from_port        = 6080 
      to_port          = 6080
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true 
    }
  ]

  tags = {
    Name = "allow_www"
  }
}
