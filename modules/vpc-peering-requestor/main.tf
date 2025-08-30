resource "aws_vpc_peering_connection" "this" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = var.vpc_id
  tags = merge(var.tags, tomap({
    "Name"                             = "${var.name}",
    "${var.project}:ModuleName"        = "vpc-peering-requestor",
    "${var.project}:TechnicalFunction" = "network"
  }))
}

# resource "aws_route" "this" {
#   for_each                  = { for id in var.route_table_ids : id => id }
#   route_table_id            = each.value
#   destination_cidr_block    = var.destination_cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.this.id
# }

resource "aws_route" "this" {
  count                     = length(var.route_table_ids)
  route_table_id            = var.route_table_ids[count.index]
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
