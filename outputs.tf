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
