provider "aws" {
  region = "ap-south-1"
  profile = "shrashti03"
}
resource "aws_vpc" "vpc_ng" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_ng"
  }
}
resource "aws_subnet" "subnet-1" {
  vpc_id     = "${aws_vpc.vpc_ig.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_1"

  }
}
resource "aws_subnet" "subnet-2" {
  vpc_id     = "${aws_vpc.vpc_ig.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "subnet_2"
  }
}
resource "aws_internet_gateway" "myig" {
  vpc_id = "${aws_vpc.vpc_ig.id}"

  tags = {
    Name = "myig"
  }
}
resource "aws_route_table" "rtvpc" {
  vpc_id = "${aws_vpc.vpc_ig.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myig.id}"
  }



  tags = {
    Name = "rtvpc"
  }
}
resource "aws_route_table_association" "sub-assoc" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.rtvpc.id
}

#creating security group
resource "aws_security_group" "webserver" {
  name        = "webserver"
  description = "Allow ssh and http traffic"
  vpc_id = "${aws_vpc.vpc_ig.id}"
  
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
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}


resource "aws_security_group" "mysqlsg" {
  name        = "mysqlsg"
  description = "Allow sql"
  vpc_id = "${aws_vpc.vpc_ig.id}"
  
  ingress {
    security_groups =  ["${aws_security_group.webserver.id}"]
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
  }
  
  ingress {
    
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}

resource "aws_security_group" "bastion-host" {
  name        = "bastion-host"
  description = "Allow ssh and http traffic"
  vpc_id = "${aws_vpc.vpc_ig.id}"
  
  ingress {
    
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
}

resource "aws_instance" "wordpress" {
  ami           = "ami-01b9cb595fc660622"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a" 
  subnet_id      = aws_subnet.subnet-1.id
  security_groups = ["${aws_security_group.webserver.id}"]
  key_name = "mykey1111"
 
  
  tags = {
    Name = "wordpress"
  }
}

resource "aws_instance" "mysql" {
  ami           = "ami-0025b3a1ef8df0c3b"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1b" 
  subnet_id      = aws_subnet.subnet-2.id
  security_groups = ["${aws_security_group.mysqlsg.id}","${aws_security_group.bastion-host.id}"]
  key_name = "mykey1111"
  
  
  tags = {
    Name = "mysql"
  }
}

resource "aws_instance" "bastion" {
  ami           = "ami-005956c5f0f757d37"
  instance_type = "t2.micro"
  availability_zone = "ap-south-1a"
  subnet_id      = aws_subnet.subnet-1.id
  security_groups = ["${aws_security_group.bastion-host.id}"]
  key_name = "mykey1111"
  
  tags = {
    Name = "bastion"
  }
}
resource "aws_eip" "task4_eip" {
vpc = true
depends_on = ["aws_internet_gateway.myigw"]

tags = {
Name = "task4-eip"
    }
}


resource "aws_nat_gateway" "task4_nat_gateway" {
  allocation_id = "${aws_eip.my_eip.id}"
  subnet_id     = "${aws_subnet.subnet1.id}"

  tags = {
    Name = "task4-nat-gateway"
  }
}
