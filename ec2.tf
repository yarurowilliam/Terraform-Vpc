# Crear el grupo de seguridad para permitir HTTP (80) y SSH (22)
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name        = "allow_http_ssh_mysql"
  description = "Security group allowing HTTP, SSH, and MySQL traffic"

  # Permitir tráfico entrante en el puerto 80 (HTTP)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico entrante en el puerto 22 (SSH)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico de salida al puerto 3306 (MySQL) hacia la VPC
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Ajusta este CIDR al rango de tu VPC
  }

  # Permitir todo el tráfico saliente (opcional, ya que estamos permitiendo 3306 explícitamente)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

# Lanzar la primera instancia EC2 en la primera subnet pública
resource "aws_instance" "web1" {
  ami           = var.ami_confg   # Cambia según tu región
  instance_type = "t2.micro"

  key_name = "cloud2"

  # Asignar la instancia a la primera subnet pública
  subnet_id = aws_subnet.public_subnet_1.id

  # Asociar al grupo de seguridad creado
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = var.docker_install_script

  tags = {
    Name = "WebServer1"
  }
}

# Lanzar la segunda instancia EC2 en la segunda subnet pública
resource "aws_instance" "web2" {
  ami           = var.ami_confg  # Cambia según tu región
  instance_type = "t2.micro"

  key_name = "cloud2"
  # Asignar la instancia a la segunda subnet pública
  subnet_id = aws_subnet.public_subnet_2.id

  # Asociar al grupo de seguridad creado
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = var.docker_install_script2
        
  tags = {
    Name = "WebServer2"
  }
}

# Crear el Target Group para las instancias EC2
resource "aws_lb_target_group" "tg" {
  name     = "ec2-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ec2-target-group"
  }
}

# Crear el Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "app-load-balancer"
  }
}

# Listener para el Load Balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Asignar las instancias EC2 al Target Group
resource "aws_lb_target_group_attachment" "tg_attachment_web1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_web2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}