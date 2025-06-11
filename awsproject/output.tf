output "loadbalancerdns" {
    value = aws_lb.eks_lb.dns_name
    description = "The DNS name of the load balancer"
  
}
