output "vpc_id" {
  description = "El ID de la VPC"
  value       = aws_vpc.my_vpc.id
}

output "public_subnets" {
  description = "IDs de las subnets públicas"
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnets" {
  description = "IDs de las subnets privadas"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "rds_endpoint" {
  value = aws_db_instance.my_rds.endpoint
}

output "instance_ips" {
  value = {
    WebServer1 = aws_instance.web1.public_ip
    WebServer2 = aws_instance.web2.public_ip
  }
}