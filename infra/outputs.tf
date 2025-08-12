output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.value.id]
}
