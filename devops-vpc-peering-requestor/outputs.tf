output "vpc-peering-accept_status" {
  description = "Request status for the connection"
  value       = aws_vpc_peering_connection.vpc-peering-requestor.accept_status
}
