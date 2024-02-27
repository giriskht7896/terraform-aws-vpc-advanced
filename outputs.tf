output "vpc_id" {
  value = aws_vpc.main.id
}
output "azs" {
  value = local.azs
}

output "public_subnets_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnets_ids" {
  value = aws_subnet.database[*].id
}
