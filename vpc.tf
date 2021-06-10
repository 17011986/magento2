module "vpc_test" {
  source          = "./modules/vpc"
  azs             = data.aws_availability_zones.available.names
  cidr_vpc        = var.vpc_cidr
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
}

resource "aws_db_subnet_group" "magento" {
  name = "main"

  subnet_ids = [
    for x in module.vpc_test.private_subnets :
    x
  ]

  tags = {
    Name = "${var.env}-rds"
  }

}
