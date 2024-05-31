output "vpc_id" {
  value       = "aws_vpc.main.id"
}

output "public_subnet_id_list"{
  value = aws_subnet.public[*].id
}

output "private_subnet_id_list"{
  value = aws_subnet.private[*].id
}

output "database_subnet_id_list"{
  value = aws_subnet.database[*].id
}

output "database_subnet_group_id_list"{
  value = aws_db_subnet_group.default.id
}






