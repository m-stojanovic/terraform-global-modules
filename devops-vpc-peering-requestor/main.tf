resource "aws_vpc_peering_connection" "vpc-peering-requestor" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = var.vpc_id
  tags          = merge(tomap({ "Name" = "${var.name}" }), var.tags)
}

resource "aws_route" "peer-route" {
  count                     = length(var.route_table_ids)
  route_table_id            = element((var.route_table_ids), count.index)
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc-peering-requestor.id
}