output "load_balancer_dns_name" {
 description = "DNS name of the load balancer"
 value = aws_lb.web_lb.dns_name
}