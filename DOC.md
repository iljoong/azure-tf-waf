### Overview

Some documentation to provision App Gateway.

- provision WAF mode
- add SSL certification
- http redirection

### Provision WAF mode

Enable WAF mode by adding following configuration

```
  waf_configuration {
    firewall_mode    = "Detection" // "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"       // "2.2.9"
    enabled          = true
  }
```
There was an documentation error on [waf_configuration] (https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html#waf_configuration) and I reported an issue at [terraform issue](https://github.com/terraform-providers/terraform-provider-azurerm/issues/1047) and the document is now updated.

### Add SSL certification

In order to add a SSL certificate to App Gateway, you need to encode to base64. You can easily encode it by built-in interpolation funcitons in terraform.

```
  ssl_certificate {
    name     = "mycertificate"
    data     = "${ base64encode( file( var.cert_path ) ) }"
    password = "${var.cert_password}"
  }
```

### HTTP redirection

Current version of terraform does not support [HTTP to HTTPS redirection]( https://github.com/terraform-providers/terraform-provider-azurerm/issues/552)

You can use `local-exec` to run `az network application-gateway` script directly. However, this will make inconsistent provision state. Do not run terraform script twice or make sure update `terraform.tfstate` manaully before run it again.

```
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
```