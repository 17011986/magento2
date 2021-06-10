data "aws_db_instance" "database" {
  db_instance_identifier = "${var.env}-rds"
  depends_on             = [aws_db_instance.magento]
}

data "aws_ssm_parameter" "my_rds_password" {
  name       = "${var.env}-rds"
  depends_on = [aws_ssm_parameter.rds_password]
}
data "aws_availability_zones" "available" {
}


resource "aws_db_instance" "magento" {

  identifier             = "${var.env}-rds"
  allocated_storage      = var.magento_db_setup["size_storage"]
  storage_type           = var.magento_db_setup["storage_type"]
  engine                 = var.magento_db_setup["type_dp"]
  engine_version         = var.magento_db_setup["version_dp"]
  instance_class         = "db.${lookup(var.ec2_size, var.env)}"
  name                   = var.magento_db_setup["db-name"]
  username               = var.magento_db_setup["db-user"]
  password               = data.aws_ssm_parameter.my_rds_password.value
  port                   = var.magento_db_setup["port_db"]
  vpc_security_group_ids = [aws_security_group.main.id]
  skip_final_snapshot    = true
  apply_immediately      = true
  db_subnet_group_name   = aws_db_subnet_group.magento.name
}


resource "aws_ssm_parameter" "rds_password" {
  name        = "${var.env}-rds"
  description = "Password for RDS"
  type        = "SecureString"
  value       = random_string.rds_password.result

}
resource "random_string" "rds_password" {
  length           = var.magento_db_setup["db-password-length"]
  special          = true
  override_special = "!#$&"

  keepers = {
    kepeer1 = var.env

  }
}
