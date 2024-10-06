# Provider de AWS en Norte de Virgina
provider "aws" {
  region = "us-east-1"
}

# Creamos la VPC en el rango establecido
resource "aws_vpc" "vpc_cloud_2" {
  cidr_block           = "30.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC_Cloud2"
  }
}

# Creamos nuestro Internet Gateway para la salida a internet de las redes publicas
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_cloud_2.id
  tags = {
    Name = "Cloud2_internet_gateway"
  }
}

# Creamos Primera SubRed Pública en una Zona Diferente
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc_cloud_2.id
  cidr_block              = "30.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet1"
  }
}

# Creamos Segunda SubRed Pública en una Zona Diferente
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc_cloud_2.id
  cidr_block              = "30.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet2"
  }
}

# Creamos Primera SubRed Privada en la misma Zona de la primera instancia publica
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc_cloud_2.id
  cidr_block        = "30.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PrivateSubnet1"
  }
}

# Creamos Segunda SubRed Privada en la misma Zona de la primera instancia publica
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc_cloud_2.id
  cidr_block        = "30.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "PrivateSubnet2"
  }
}

# Creamos la tabla de rutas para las Subredes Públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_cloud_2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Asociamos tabla de rutas públicas con la Primera Subred Pública para su conexion a internet
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Asociamos tabla de rutas públicas con la Segunda Subred Pública para su conexion a internet
resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Creamos tabla de rutas para Subredes Privadas 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_cloud_2.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

# Asociamos tabla de rutas Privadas con la primera Subred Privada
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

# Asociamos tabla de rutas Privadas con la Segunda Subred Privada
resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Creamos el grupo de seguridad para las instancias EC2
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.vpc_cloud_2.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = {
    Name = "MySecurityGroup"
  }
}

# Creamos instancia de EC2 en la Subred Pública 1
resource "aws_instance" "public_ec2_1" {
  ami                    = "ami-0fff1b9a61dec8a5f" # Amazon Linux 2 AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  key_name               = "cloud2"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  user_data = file("command.sh")

  tags = {
    Name = "PublicEC2-1"
  }
}

# Creamos la otra instancia de EC2 en la Subred Pública 2
resource "aws_instance" "public_ec2_2" {
  ami                    = "ami-0fff1b9a61dec8a5f" # Amazon Linux 2 AMI ID
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  associate_public_ip_address = true
  key_name               = "cloud2"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  user_data = file("command2.sh")

  tags = {
    Name = "PublicEC2-2"
  }
}