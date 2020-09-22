###################################################
# Route53

resource "aws_route53_zone" "ocp3" {
  name    = var.r53_ocp_private_zone_name
  comment = var.r53_ocp_private_zone_comment

  vpc {
    vpc_id = var.vpc_id 
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.r53_ocp_private_zone_name
    }
  )
}

resource "aws_route53_zone" "ocp3_apps" {
  name     = var.r53_ocp_apps_private_zone_name
  comment  = var.r53_ocp_apps_private_zone_comment

  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.r53_ocp_apps_private_zone_name
    }
  )
}

resource "aws_route53_record" "ocp3_master_api_dns" {
  zone_id = aws_route53_zone.ocp3.zone_id
  name    = "fx"
  type    = "A"

  alias {
    name                   = aws_lb.ocp3-master-api.dns_name
    zone_id                = aws_lb.ocp3-master-api.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ocp3_router_wildcard_dns" {
  zone_id = aws_route53_zone.ocp3_apps.zone_id
  name    = "*"
  type    = "A"

  alias {
    name                   = aws_lb.ocp3-router-int.dns_name
    zone_id                = aws_lb.ocp3-router-int.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ocp3_master_node_dns" {
  count = length(var.ocp3_master_instances) > 0 ? length(var.ocp3_master_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z0-9]+$", var.ocp3_master_instances[count.index])
  type    = "A"
  ttl     = "300"
  
  records = [element(aws_instance.ocp3_master[*].private_ip, count.index)]
}

resource "aws_route53_record" "ocp3_router_int_node_dns" {
  count = length(var.ocp3_router_int_instances) > 0 ? length(var.ocp3_router_int_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z0-9]+$", var.ocp3_router_int_instances[count.index])
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.ocp3_router_int[*].private_ip, count.index)]
}

resource "aws_route53_record" "ocp3_router_ext_node_dns" {
  count = length(var.ocp3_router_ext_instances) > 0 ? length(var.ocp3_router_ext_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z0-9]+$", var.ocp3_router_ext_instances[count.index])
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.ocp3_router_ext[*].private_ip, count.index)]
}

resource "aws_route53_record" "ocp3_compute_node_dns" {
  count = length(var.ocp3_compute_instances) > 0 ? length(var.ocp3_compute_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z0-9]+$", var.ocp3_compute_instances[count.index])
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.ocp3_compute[*].private_ip, count.index)]
}

resource "aws_route53_record" "ocp3_infra_node_dns" {
  count = length(var.ocp3_infra_instances) > 0 ? length(var.ocp3_infra_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z0-9]+$", var.ocp3_infra_instances[count.index])
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.ocp3_infra[*].private_ip, count.index)]
}

resource "aws_route53_record" "ocp3_admin_node_dns" {
  count = length(var.ocp3_admin_instances) > 0 ? length(var.ocp3_admin_instances) : 0

  zone_id = aws_route53_zone.ocp3.zone_id
  name    = regex("[a-z]+[0-9]*$", var.ocp3_admin_instances[count.index])
  type    = "A"
  ttl     = "300"

  records = [element(aws_instance.ocp3_admin[*].private_ip, count.index)]
}
