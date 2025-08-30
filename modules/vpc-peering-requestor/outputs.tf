output "vpc_peering_accept_status" {
  description = "Request status for the connection"
  value       = aws_vpc_peering_connection.this.accept_status
}
