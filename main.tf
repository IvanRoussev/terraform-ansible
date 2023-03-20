provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "acit-4640-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "acit-4640-vpc"
  }
}

#----------------------------------------------------------------------

resource "aws_subnet" "acit-4640-pub-sub" {
  vpc_id                  = aws_vpc.acit-4640-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "acit-4640-pub-sub"
  }
}


resource "aws_subnet" "acit-4640-rds-sub1" {
  vpc_id            = aws_vpc.acit-4640-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "acit-4640-rds-sub1"
  }
}

resource "aws_subnet" "acit-4640-rds-sub2" {
  vpc_id            = aws_vpc.acit-4640-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "acit-4640-rds-sub2"
  }
}

#----------------------------------------------------------------------

resource "aws_internet_gateway" "acit-4640-igw" {
  vpc_id = aws_vpc.acit-4640-vpc.id

  tags = {
    Name = "acit-4640-igw"
  }
}


#----------------------------------------------------------------------

resource "aws_route_table" "acit_4640_rt" {
  vpc_id = aws_vpc.acit-4640-vpc.id
  tags = {
    Name = "acit-4640-rt"
  }
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.acit_4640_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.acit-4640-igw.id
}

resource "aws_route_table_association" "acit_4640_rt_assoc" {
  subnet_id      = aws_subnet.acit-4640-pub-sub.id
  route_table_id = aws_route_table.acit_4640_rt.id
}


#------------------------------------------------------------------------

resource "aws_security_group" "acit-4640-sg-ec2" {
  name        = "acit-4640-sg-ec2"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = aws_vpc.acit-4640-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "acit-4640-sg-ec2"
  }
}


resource "aws_security_group" "acit-4640-sg-rds" {
  name        = "acit-4640-sg-rds"
  description = "Allow Mysql traffic within the VPC"
  vpc_id      = aws_vpc.acit-4640-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.acit-4640-vpc.cidr_block]
  }

  tags = {
    Name = "acit-4640-sg-rds"
  }
}



#-------------------------------------------------------------------------
resource "aws_instance" "acit-4640-ec2" {
  ami                    = "ami-0735c191cf914754d"
  instance_type          = "t2.micro"
  key_name               = "acit-4640-key"
  vpc_security_group_ids = [aws_security_group.acit-4640-sg-ec2.id]
  subnet_id              = aws_subnet.acit-4640-pub-sub.id

  tags = {
    Name = "acit-4640-ec2"
  }
}


resource "aws_key_pair" "acit-4640-key" {
  key_name   = "acit-4640-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbE6qs9NFyMLNfVq/2A/miqIeCOwolgCzLh8JkklBsp ivan@ivan"
}

output "instance_public_ip" {
  value = ["${aws_instance.acit-4640-ec2.public_ip}"]
}
#-------------------------------------------------------------------------

resource "aws_db_subnet_group" "acit-4640-rds-subnet-group" {
  name       = "acit-4640-rds"
  subnet_ids = [aws_subnet.acit-4640-rds-sub1.id, aws_subnet.acit-4640-rds-sub2.id]
  tags = {
    Name = "acit-4640-rds"
  }
}

resource "aws_db_instance" "acit_4640_rds" {
  engine                  = "mysql"
  engine_version          = "8.0.28"
  instance_class          = "db.t3.micro"
  db_name                 = "acit4640rds"
  username                = "admin"
  password                = "Password"
  allocated_storage       = 10
  skip_final_snapshot     = true
  apply_immediately       = true
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.acit-4640-rds-subnet-group.name
  vpc_security_group_ids  = [aws_security_group.acit-4640-sg-rds.id]
}



output "rds_endpoint" {
  value = "${aws_db_instance.acit_4640_rds.endpoint}"
}












