resource "aws_lb_target_group" "varnish" {
  name     = var.EC2_name["EC21"]
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc_test.vpc_id
  tags     = merge(var.common_tags)
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/health_check.php"
    port                = "80"
  }
}

resource "aws_lb_target_group_attachment" "varnish" {
  target_group_arn = aws_lb_target_group.varnish.arn
  target_id        = aws_instance.varnish.id
  port             = 80
}
