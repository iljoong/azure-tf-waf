# README

## Provisioning WAF using terraform

Sample terraform script for provisioning App Gateway.

## Feature highlight

- enable WAF mode
- add a SSL certificate for SSL termination/offloading
- enable HTTP to HTTPS redirection (using `az cli`)

For more information, please refer [DOC.md](./DOC.md)

## How to run

Please read [azure-terraform](https://github.com/iljoong/azure-terraform) document first.

It is required to run [azure-terraform](https://github.com/iljoong/azure-terraform) script first for setting up backend services.
It is also assumed that a private IP of VM for backendpool is `10.0.1.4`. If could modify/add IPs pool manually in `backend_address_pool` section.

```
  backend_address_pool {
    name            = "${var.prefix}-beappool1"
    ip_address_list = ["10.0.1.4"]
  }
```

Note that, you need a valid SSL certificate to perform this script. If you don't have it then you could try [let's encrypt](https://letsencrypt.org) to get a free SSL certificate. Then, update below variable in `variable.tf`

```
variable "cert_path" {
  default = "cert/mycertificate.pfx"
}

variable "cert_password" {
  default = "add password"
}
```

_Http-to-https redirection_ is not currently supported by terraform and this script leverage `az cli` to configure redirection.
If you don't want configure redirection or `az cli` is not installed then remove the last part of the script.

## How to test

Once this script finished, copy the FQDN of App Gateway and create new CNAME DNS record, such as `waf.example.org`.

Browse `https://waf.example.org` and `http://waf.example.org`



