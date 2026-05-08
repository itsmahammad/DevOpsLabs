resource "azurerm_public_ip" "appgw" {
  name                = "pip-${var.project_name}-appgw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_web_application_firewall_policy" "main" {
  name                = "waf-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }
  custom_rules {
    name      = "AllowAnalyzeAPI"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Allow"

    match_conditions {
      match_variables {
        variable_name = "RequestUri"
      }

      operator           = "Contains"
      negation_condition = false
      match_values       = ["/api/analyze"]
    }
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "main" {
  name                = "agw-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_web_application_firewall_policy.main.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  ssl_certificate {
    name     = "ssl-cert"
    data     = filebase64("${path.module}/cert.pfx")
    password = "12345678"
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "appgw-public-frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.appgw_subnet_id
  }

  frontend_ip_configuration {
    name                 = "appgw-public-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_port {
    name = "port-http"
    port = 80
  }

  backend_address_pool {
    name         = "pool-frontend-ilb"
    ip_addresses = [var.frontend_ilb_ip]
  }

  backend_address_pool {
    name         = "pool-backend-ilb"
    ip_addresses = [var.backend_ilb_ip]
  }

  backend_http_settings {
    name                  = "settings-frontend-http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-frontend"
  }

  backend_http_settings {
    name                  = "settings-backend-http"
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 30
    probe_name            = "probe-backend"
  }

  probe {
    name                                      = "probe-frontend"
    protocol                                  = "Http"
    host                                      = var.frontend_ilb_ip
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
  }

  probe {
    name                                      = "probe-backend"
    protocol                                  = "Http"
    host                                      = var.backend_ilb_ip
    path                                      = "/api/health"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = false
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "appgw-public-frontend-ip"
    frontend_port_name             = "port-http"
    protocol                       = "Http"
  }

  url_path_map {
    name                               = "path-map-main"
    default_backend_address_pool_name  = "pool-frontend-ilb"
    default_backend_http_settings_name = "settings-frontend-http"

    path_rule {
      name                       = "api-route"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "pool-backend-ilb"
      backend_http_settings_name = "settings-backend-http"
    }
  }

  request_routing_rule {
    name               = "rule-main"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "path-map-main"
    priority           = 100
  }

  request_routing_rule {
    name                       = "rule-https"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "pool-frontend-ilb"
    backend_http_settings_name = "settings-frontend-http"
    priority                   = 200
  }
}

