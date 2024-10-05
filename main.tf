# Provider de AWS
provider "aws" {
  region = "us-east-2"  # Cambiado a us-east-2 (Ohio)
}

# Crear VPC con rango 30.0.0.0/16
resource "aws_vpc" "my_vpc" {
  cidr_block       = "30.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_vpc"
  }
}

# Crear 2 Subnets Públicas
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"  # Cambiada a us-east-2a

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"  # Cambiada a us-east-2b

  tags = {
    Name = "public_subnet_2"
  }
}

# Crear 2 Subnets Privadas
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.3.0/24"
  availability_zone = "us-east-2a"  # Cambiada a us-east-2a

  tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.4.0/24"
  availability_zone = "us-east-2b"  # Cambiada a us-east-2b

  tags = {
    Name = "private_subnet_2"
  }
}

# Crear una Gateway de Internet para las subnets públicas
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_internet_gateway"
  }
}

# Crear una tabla de rutas para las subnets públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Asociar subnets públicas a la tabla de rutas pública
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Crear tabla de rutas para las subnets privadas (sin acceso a Internet)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "private_route_table"
  }
}

# Asociar subnets privadas a la tabla de rutas privada
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}