# Provider de AWS
provider "aws" {
  region = "us-east-2"  # Usamos la región us-east-2
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

# Crear 2 Subnets Públicas en diferentes zonas
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"  # Zona 1

  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "30.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-2b"  # Zona 2

  tags = {
    Name = "public_subnet_2"
  }
}

# ----------- EC2 Instances --------------

# Crear una instancia EC2 en la Subnet Pública 1
resource "aws_instance" "ec2_instance_1" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (puedes cambiarla según tu caso)
  instance_type = "t2.micro"  # Tipo de instancia, puede ser cambiado
  subnet_id     = aws_subnet.public_subnet_1.id  # Subnet pública 1
  associate_public_ip_address = true  # Asegura que la instancia tenga una IP pública
  key_name      = "cloud2"  # Asegúrate de tener un key_pair creado

  tags = {
    Name = "EC2_Public_Subnet_1"
  }
}

# Crear una instancia EC2 en la Subnet Pública 2
resource "aws_instance" "ec2_instance_2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (puedes cambiarla según tu caso)
  instance_type = "t2.micro"  # Tipo de instancia, puede ser cambiado
  subnet_id     = aws_subnet.public_subnet_2.id  # Subnet pública 2
  associate_public_ip_address = true  # Asegura que la instancia tenga una IP pública
  key_name      = "cloud2"  # Asegúrate de tener un key_pair creado

  tags = {
    Name = "EC2_Public_Subnet_2"
  }
}

# Security Group para permitir acceso SSH (puerto 22) y HTTP (puerto 80)
resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.my_vpc.id

  # Reglas de ingreso (inbound) para el puerto 22 (SSH) y el puerto 80 (HTTP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acceso SSH desde cualquier lugar
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Acceso HTTP desde cualquier lugar
  }

  # Reglas de egreso (outbound) para permitir cualquier tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Permitir todo el tráfico saliente
  }

  tags = {
    Name = "allow_ssh_http"
  }
}

# Asociar el security group a las instancias EC2
resource "aws_network_interface_sg_attachment" "sg_attachment_1" {
  security_group_id    = aws_security_group.allow_ssh_http.id
  network_interface_id = aws_instance.ec2_instance_1.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "sg_attachment_2" {
  security_group_id    = aws_security_group.allow_ssh_http.id
  network_interface_id = aws_instance.ec2_instance_2.primary_network_interface_id
}