resource "aws_security_group" "main" {
  name   = var.env
  vpc_id = module.vpc_test.vpc_id
  dynamic "ingress" {
    for_each = [for x in var.port_SG :
    x]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
