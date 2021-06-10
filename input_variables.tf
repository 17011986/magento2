
# Enter the value "prod" if you need magento latest version and example store
#(note the increased cost instance will be used).
# Or "dev" magento 2.3.5 (no store example)
variable "env" {
  default = "dev"
}
variable "region" {
  default = ""
}

variable "access_key" {
  default = ""
}
variable "secret_key" {
  default = ""
}
#Enter tags
variable "common_tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
    Name    = "Magento+Varnish"
    Owner   = "Vitalii.V"
    Project = "Terraform"

  }
}
variable "ec2_size" {
  default = {
    "dev"  = "t2.micro"
    "prod" = "t2.medium"
  }
}
variable "EC2_name" {
  description = "EC2 name"
  type        = map
  default = {
    EC21 = "Varnish"
    EC22 = "Magento"
  }
}
#Enter ssh pub key to access servers
variable "key_ssh_pub" {
  type = map
  default = {
    "dev"  = ""
    "user" = ""
  }
}
#If you selected "prod" please enter your magento access keys
#(visit https://marketplace.magento.com/customer/accessKeys/)
variable "key_magento" {
  type = map
  default = {
    "user" = ""
    "pass" = ""
  }
}
#Enter your magento installation details
variable "magento_db_setup" {

  default = {
    "type_dp"           = "mysql"
    "version_dp"        = "5.7"
    "port_db"           = 3306
    "size_storage"      = 25
    "storage_type"      = "gp2"
    "db-name"           = "magento"
    "db-user"           = "magento"
    "db-password-length"= 12
    "backend-frontname" = "admin"
    "admin-firstname"   = "admin"
    "admin-lastname"    = "admin"
    "admin-email"       = "admin@admin.com"
    "admin-user"        = "admin"
    "admin-password"    = "admin123"
    "language"          = "en_US"
    "currency"          = "USD"
    "timezone"          = "America/Chicago"
  }
}
variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24",
  ]
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "port_SG" {
  default = [
    "3306",
    "80",    
    "22",
    "443"
  ]
}
