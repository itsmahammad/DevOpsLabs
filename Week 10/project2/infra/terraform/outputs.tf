output "resource_group_name" {
  value = module.network.resource_group_name
}

output "vnet_name" {
  value = module.network.vnet_name
}

output "frontend_private_ip" {
  value = module.compute.frontend_private_ip
}

output "backend_private_ip" {
  value = module.compute.backend_private_ip
}

output "ops_private_ip" {
  value = module.compute.ops_private_ip
}

output "ops_public_ip" {
  value = module.compute.ops_public_ip
}

output "frontend_ilb_private_ip" {
  value = module.load_balancer.frontend_ilb_private_ip
}

output "backend_ilb_private_ip" {
  value = module.load_balancer.backend_ilb_private_ip
}

output "appgw_public_ip" {
  value = module.app_gateway.appgw_public_ip
}

output "appgw_name" {
  value = module.app_gateway.appgw_name
}

output "nat_public_ip" {
  value = module.nat_gateway.nat_public_ip
}
