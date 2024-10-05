variable "region" {
  description = "La región donde se desplegará la VPC"
  default     = "us-east-2"  # Cambiado a us-east-2
}

variable "vpc_cidr" {
  description = "El CIDR block para la VPC"
  default     = "30.0.0.0/16"
}

variable "ami_confg" {
  description = "Configuración de la AMI"
  default     = "ami-09da212cf18033880"
}

variable "docker_install_script" {
  type = string
  default = <<-EOF
    #!/bin/bash
    # Actualiza los paquetes instalados
    sudo dnf update -y

    # Instala Docker usando el repositorio de Amazon Linux
    sudo dnf install docker -y

    # Inicia Docker
    sudo systemctl start docker

    # Habilita Docker para que inicie con el sistema
    sudo systemctl enable docker

    # Agrega al usuario ec2-user al grupo docker
    sudo usermod -aG docker ec2-user

    # Esperar hasta que el servicio de Docker esté activo
    until sudo systemctl is-active --quiet docker; do
      echo "Esperando a que Docker inicie..."
      sleep 3
    done

    # Crear un archivo HTML personalizado
    echo "<html>
    <head><title>Ingeniero Devops William</title></head>
    <body><h1>Titulo personalizado por tu DevOps Favorito BB</h1></body>
    </html>" > /home/ec2-user/custom_index.html

    # Ejecutar el contenedor de Nginx con el archivo HTML personalizado montado
    sudo docker run -d -p 80:80 --name nginx-container -v /home/ec2-user/custom_index.html:/usr/share/nginx/html/index.html nginx
  EOF
}