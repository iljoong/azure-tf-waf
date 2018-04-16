# azure service principal info
variable "subscription_id" {
  default = "add_here"
}

# client_id or app_id
variable "client_id" {
  default = "add_here"
}

variable "client_secret" {
  default = "add_here"
}

# tenant_id or directory_id
variable "tenant_id" {
  default = "add_here"
}

# admin password
variable "admin_username" {
  default = "azureuser"
}

variable "admin_keydata" {
  default = "add_here"
}

variable "admin_password" {
  default = "add_here"
}

# service variables
variable "prefix" {
  default = "tfdemo"
}

variable "location" {
  default = "koreasouth"
}

variable "vmsize" {
  default = "Standard_DS1_v2"
}

variable "osimageuri" {
  default = "add_here"
}

variable "webcount" {
  default = 1
}

variable "appcount" {
  default = 1
}

variable "cert_path" {
  default = "cert/mycertificate.pfx"
}

variable "cert_password" {
  default = "add_password"
}

variable "tag" {
  default = "demo"
}
