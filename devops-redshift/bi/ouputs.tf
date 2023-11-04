output "this_redshift_db_dns_name" {
  value = aws_redshift_cluster.this.dns_name
}

output "this_redshift_db_name" {
  value = aws_redshift_cluster.this.database_name
}

output "this_security_group_id" {
  value = aws_security_group.redhsift_db_access_sg.id
}