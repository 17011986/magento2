resource "aws_instance" "varnish" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.ec2_size["dev"]
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = module.vpc_test.public_subnets[0]
  user_data = templatefile("terraform_user_data_varnish.sh.tpl", {
    alb_dns      = aws_lb.magento.dns_name,
    key_ssh_dev  = var.key_ssh_pub["dev"],
    key_ssh_user = var.key_ssh_pub["user"],
    ip_magento   = aws_instance.magento.private_ip
  })
  depends_on = [aws_instance.magento]

  tags = merge(var.common_tags, { Name = "${var.EC2_name["EC21"]}" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "magento" {
  ami                    = data.aws_ami.ami.id
  instance_type          = lookup(var.ec2_size, var.env)
  vpc_security_group_ids = [aws_security_group.main.id]
  # vpc_id                 = module.vpc.vpc_id

  subnet_id = module.vpc_test.public_subnets[0]
  user_data = var.env == "prod" ? templatefile("terraform.sh.tpl", {
    alb_dns           = aws_lb.magento.dns_name,
    key_ssh_dev       = var.key_ssh_pub["dev"],
    key_ssh_user      = var.key_ssh_pub["user"],
    users_mag         = var.key_magento["user"],
    pass_mag          = var.key_magento["pass"],
    db-name           = var.magento_db_setup["db-name"],
    db-user           = var.magento_db_setup["db-user"],
    db-host           = data.aws_db_instance.database.address,
    db-password       = data.aws_ssm_parameter.my_rds_password.value,
    backend-frontname = var.magento_db_setup["backend-frontname"],
    admin-firstname   = var.magento_db_setup["admin-firstname"],
    admin-lastname    = var.magento_db_setup["admin-lastname"],
    admin-email       = var.magento_db_setup["admin-email"],
    admin-user        = var.magento_db_setup["admin-user"],
    admin-password    = var.magento_db_setup["admin-password"],
    language          = var.magento_db_setup["language"],
    currency          = var.magento_db_setup["currency"],
    timezone          = var.magento_db_setup["timezone"], }) : templatefile("terraform_user_data_magento.sh.tpl", {
    alb_dns           = aws_lb.magento.dns_name,
    key_ssh_dev       = var.key_ssh_pub["dev"],
    key_ssh_user      = var.key_ssh_pub["user"],
    db-name           = var.magento_db_setup["db-name"],
    db-host           = data.aws_db_instance.database.address,
    db-user           = var.magento_db_setup["db-user"],
    db-password       = data.aws_ssm_parameter.my_rds_password.value,
    backend-frontname = var.magento_db_setup["backend-frontname"],
    admin-firstname   = var.magento_db_setup["admin-firstname"],
    admin-lastname    = var.magento_db_setup["admin-lastname"],
    admin-email       = var.magento_db_setup["admin-email"],
    admin-user        = var.magento_db_setup["admin-user"],
    admin-password    = var.magento_db_setup["admin-password"],
    language          = var.magento_db_setup["language"],
    currency          = var.magento_db_setup["currency"],
    timezone          = var.magento_db_setup["timezone"],


  })
  tags = merge(var.common_tags, { Name = "${var.EC2_name["EC22"]}" })

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_db_instance.magento]
}
