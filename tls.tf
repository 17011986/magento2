resource "tls_private_key" "magento" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.magento.private_key_pem

  subject {
    common_name  = aws_lb.magento.dns_name
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 43800

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.magento.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
  # lifecycle {
  #   create_before_destroy = true
  # }

}
