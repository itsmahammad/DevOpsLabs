module "network" {
  source          = "./modules/network"
  project_name    = var.project_name
  environment     = var.environment
  location        = var.location
  admin_public_ip = var.admin_public_ip
}

module "compute" {
  source              = "./modules/compute"
  project_name        = var.project_name
  environment         = var.environment
  location            = module.network.location
  resource_group_name = module.network.resource_group_name

  frontend_subnet_id = module.network.frontend_subnet_id
  backend_subnet_id  = module.network.backend_subnet_id
  ops_subnet_id      = module.network.ops_subnet_id

  admin_username = var.admin_username
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}

module "load_balancer" {
  source              = "./modules/load-balancer"
  project_name        = var.project_name
  environment         = var.environment
  location            = module.network.location
  resource_group_name = module.network.resource_group_name

  frontend_subnet_id = module.network.frontend_subnet_id
  backend_subnet_id  = module.network.backend_subnet_id

  frontend_nic_id = module.compute.frontend_nic_id
  backend_nic_id  = module.compute.backend_nic_id
}

module "app_gateway" {
  source              = "./modules/app-gateway"
  project_name        = var.project_name
  environment         = var.environment
  location            = module.network.location
  resource_group_name = module.network.resource_group_name

  appgw_subnet_id = module.network.appgw_subnet_id

  frontend_ilb_ip = module.load_balancer.frontend_ilb_private_ip
  backend_ilb_ip  = module.load_balancer.backend_ilb_private_ip
}

module "nat_gateway" {
  source              = "./modules/nat-gateway"
  project_name        = var.project_name
  environment         = var.environment
  location            = module.network.location
  resource_group_name = module.network.resource_group_name

  frontend_subnet_id = module.network.frontend_subnet_id
  backend_subnet_id  = module.network.backend_subnet_id
  ops_subnet_id      = module.network.ops_subnet_id
}
