output "web_loadbalancer_url" {
  value = aws_lb.magento.dns_name
}
output "rds_output" {
  value = data.aws_db_instance.database.address
}
