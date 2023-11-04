resource "aws_vpc_peering_connection_accepter" "vpc-peering-acceptter" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true
  tags                      = merge(tomap({ "Name" = "${var.name}" }), var.tags)
}

resource "aws_route" "peer-route" {
  count                     = length(var.route_table_ids)
  route_table_id            = element((var.route_table_ids), count.index)
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}