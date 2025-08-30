
### How to use module
```
module "vpc-peering-acceptor" {
  source = ""

  for_each                  = var.peering_accept
  vpc_peering_connection_id = each.value.pcx_id
  route_table_ids           = setunion(module.network.private_route_table_ids, module.network.public_route_table_ids)
  destination_cidr_block    = each.value.destination_cidr_block
  name                      = each.key
}
```

### How to create peering requests

```
peering_accept = {
  account = {
    pcx_id                 = ""
    destination_cidr_block = ""
  }
}
```
