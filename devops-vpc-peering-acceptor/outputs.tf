output "vpc-peering-accept_status" {
  description = "Accept status for the connection"
  value       = aws_vpc_peering_connection_accepter.vpc-peering-acceptter.accept_status
}
