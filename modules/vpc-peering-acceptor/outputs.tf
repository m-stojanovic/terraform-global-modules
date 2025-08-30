output "vpc_peering_accept_status" {
  description = "Accept status for the connection"
  value       = aws_vpc_peering_connection_accepter.this.accept_status
}
