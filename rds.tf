# Crear el grupo de seguridad para la base de datos RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow access to RDS from EC2"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]  # Permitir acceso desde las instancias EC2
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# Crear la instancia de RDS MySQL en la capa gratuita
resource "aws_db_instance" "my_rds" {
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro" # Instancia gratuita
  db_name              = "mysqlnew"
  username             = "admin"
  password             = "yaruro123"
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false # Asegurarse de que solo las instancias EC2 puedan acceder

  tags = {
    Name = "my-rds-instance"
  }
}

# Subnet group para RDS
resource "aws_db_subnet_group" "default" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "rds-subnet-group"
  }
}