resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true
  tags = merge(var.tags, tomap({
    "Name"                             = "${var.name}",
    "${var.project}:ModuleName"        = "vpc-peering-acceptor",
    "${var.project}:TechnicalFunction" = "network"
  }))
}

resource "aws_route" "this" {
  for_each                  = { for id in var.route_table_ids : id => id }
  route_table_id            = each.value
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = var.vpc_peering_connection_id
}
