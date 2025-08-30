
### How to use module
```
module "vpc-peering-requestor" {
  source = ""

  for_each = var.peering_requests

  vpc_id                 = module.network.vpc_id
  peer_owner_id          = each.value.peer_owner_id
  peer_vpc_id            = each.value.peer_vpc_id
  peer_region            = each.value.peer_region
  name                   = each.key
  route_table_ids        = setunion(module.network.private_route_table_ids, module.network.public_route_table_ids)
  destination_cidr_block = each.value.destination_cidr_block
}
```

### How to create peering requests

```
peering_request = {
  account-us-east-1 = {
    peer_vpc_id            = ""
    peer_owner_id          = ""
    destination_cidr_block = ""
    peer_region            = "us-east-1"
  }
  account-ap-southeast-1 = {
    peer_vpc_id            = ""
    peer_owner_id          = ""
    destination_cidr_block = ""
    peer_region            = "ap-southeast-1"
  }
  account-ap-southeast-1 = {
    peer_vpc_id            = ""
    peer_owner_id          = ""
    destination_cidr_block = ""
    peer_region            = "ap-southeast-1"
  }
}
```
