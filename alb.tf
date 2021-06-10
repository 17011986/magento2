resource "aws_lb" "magento" {
  name            = lower(var.EC2_name["EC22"])
  internal        = false
  security_groups = [aws_security_group.main.id]
  subnets         = module.vpc_test.public_subnets
  tags            = merge(var.common_tags)

  # enable_deletion_protection = true

}
resource "aws_lb_listener" "test" {
  load_balancer_arn = aws_lb.magento.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.id
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.varnish.arn
  }
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.magento.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
