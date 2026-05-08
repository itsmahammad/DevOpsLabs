resource "azurerm_lb" "frontend" {
  name                = "ilb-${var.project_name}-frontend-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend-ilb-ip"
    subnet_id                     = var.frontend_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.2.100"
  }
}

resource "azurerm_lb_backend_address_pool" "frontend" {
  name            = "pool-frontend"
  loadbalancer_id = azurerm_lb.frontend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "frontend" {
  network_interface_id    = var.frontend_nic_id
  ip_configuration_name   = "ipconfig-frontend"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend.id
}

resource "azurerm_lb_probe" "frontend" {
  name            = "probe-frontend-http"
  loadbalancer_id = azurerm_lb.frontend.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "frontend" {
  name                           = "rule-frontend-http"
  loadbalancer_id                = azurerm_lb.frontend.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ilb-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.frontend.id]
  probe_id                       = azurerm_lb_probe.frontend.id
}

resource "azurerm_lb" "backend" {
  name                = "ilb-${var.project_name}-backend-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "backend-ilb-ip"
    subnet_id                     = var.backend_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.3.100"
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  name            = "pool-backend"
  loadbalancer_id = azurerm_lb.backend.id
}

resource "azurerm_network_interface_backend_address_pool_association" "backend" {
  network_interface_id    = var.backend_nic_id
  ip_configuration_name   = "ipconfig-backend"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}

resource "azurerm_lb_probe" "backend" {
  name            = "probe-backend-http"
  loadbalancer_id = azurerm_lb.backend.id
  protocol        = "Http"
  port            = 8080
  request_path    = "/api/health"
}

resource "azurerm_lb_rule" "backend" {
  name                           = "rule-backend-http"
  loadbalancer_id                = azurerm_lb.backend.id
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "backend-ilb-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
  probe_id                       = azurerm_lb_probe.backend.id
}
