output "ocp3_master_private_hostnames" {
  value = aws_instance.ocp3_master[*].private_dns
}

output "ocp3_router_int_private_hostnames" {
  value = aws_instance.ocp3_router_int[*].private_dns
}

output "ocp3_router_ext_private_hostnames" {
  value = aws_instance.ocp3_router_ext[*].private_dns
}

output "ocp3_compute_private_hostnames" {
  value = aws_instance.ocp3_compute[*].private_dns
}

output "ocp3_infra_private_hostnames" {
  value = aws_instance.ocp3_infra[*].private_dns
}

output "ocp3_admin_private_hostnames" {
  value = aws_instance.ocp3_admin[*].private_dns
}

output "ocp3_master_api_url" {
  value = trim(format("https://fx.%s", aws_route53_zone.ocp3.name), ".")
}
