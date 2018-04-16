resource "azurerm_public_ip" "wafip" {
  name                         = "${var.prefix}-wafip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.tfrg.name}"
  public_ip_address_allocation = "dynamic"

  tags {
    environment = "${var.tag}"
  }
}

# Create an application gateway
resource "azurerm_application_gateway" "appgw" {
  name                = "${var.prefix}appgw"
  resource_group_name = "${azurerm_resource_group.tfrg.name}"
  location            = "${var.location}"

  # WAF configuration
  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 1
  }

  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }

  gateway_ip_configuration {
    name      = "ip-configuration"
    subnet_id = "${azurerm_subnet.tfwafnet.id}"
  }

  frontend_port {
    name = "${var.prefix}-feport443"
    port = 443
  }

  frontend_port {
    name = "${var.prefix}-feport"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${var.prefix}-feip"
    public_ip_address_id = "${azurerm_public_ip.wafip.id}"
  }

  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    ip_address_list = ["10.0.1.4"]
  }

  backend_http_settings {
    name                  = "${var.prefix}-httpsetting1"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    cookie_based_affinity = "Enabled"                    // "Disabled"
  }

  http_listener {
    name                           = "${var.prefix}-httplstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport"
    protocol                       = "Http"
    ssl_certificate_name           = "mycertificate"
  }

  http_listener {
    name                           = "${var.prefix}-httpslstn1"
    frontend_ip_configuration_name = "${var.prefix}-feip"
    frontend_port_name             = "${var.prefix}-feport443"
    protocol                       = "Https"
    ssl_certificate_name           = "mycertificate"
  }

  request_routing_rule {
    name                       = "${var.prefix}-rule1"
    rule_type                  = "Basic"
    http_listener_name         = "${var.prefix}-httpslstn1"
    backend_address_pool_name  = "${var.prefix}-beappool1"
    backend_http_settings_name = "${var.prefix}-httpsetting1"
  }

  ssl_certificate {
    name     = "mycertificate"
    data     = "${ base64encode( file( var.cert_path ) ) }"
    password = "${var.cert_password}"
  }
}

####################### UNCOMMENT BELOW IF YOU WANT TO RUN AZ CLI SCRIPT ##########################
/*
# http redirect workaround
resource "null_resource" "redirect-config" {
  triggers {
    gateway = "${azurerm_application_gateway.appgw.name}"
  }

  provisioner "local-exec" {
    command = <<EOF
      az network application-gateway redirect-config create \
        --gateway-name ${azurerm_application_gateway.appgw.name} \
        -g ${azurerm_resource_group.tfrg.name} \
        -n httpredirect1 \
        --type Permanent \
        --include-path true \
        --include-query-string true \
        --target-listener ${var.prefix}-httpslstn1
    EOF
  }
}

resource "null_resource" "redirect-rule" {
  triggers {
    gateway = "${azurerm_application_gateway.appgw.name}"
  }

  provisioner "local-exec" {
    command = <<EOF
      az network application-gateway rule create \
        --gateway-name ${azurerm_application_gateway.appgw.name} \
        -g ${azurerm_resource_group.tfrg.name} \
        -n http-redirect \
        --rule-type Basic \
        --http-listener ${var.prefix}-httplstn1 \
        --redirect-config httpredirect1
    EOF
  }

  depends_on = ["null_resource.redirect-config"]
}
*/

