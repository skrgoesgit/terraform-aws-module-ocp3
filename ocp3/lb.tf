###################################################
# Loadbalancing

########################################
# LB OCP3 master api

resource "aws_lb" "ocp3-master-api" {
  name                       = var.lb_name_master_api
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.ocp3_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      "Name" = var.lb_name_master_api
    }
  )
}

resource "aws_lb_listener" "ocp3-master-api" {
  load_balancer_arn = aws_lb.ocp3-master-api.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp3-master-api.arn
  }
}

resource "aws_lb_target_group" "ocp3-master-api" {
  name        = var.lb_target_group_name_master_api
  port        = 443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.lb_target_group_name_master_api
    }
  )
}

resource "aws_lb_target_group_attachment" "ocp3-master-api" {
  count = length(var.ocp3_master_instances) > 0 ? length(var.ocp3_master_instances) : 0

  target_group_arn = aws_lb_target_group.ocp3-master-api.arn
  target_id        = element(aws_instance.ocp3_master[*].private_ip, count.index)
  port             = 443
}

########################################
# LB OCP3 router int

resource "aws_lb" "ocp3-router-int" {
  name                       = var.lb_name_router_int
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.ocp3_subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      "Name" = var.lb_name_router_int
    }
  )
}

resource "aws_lb_listener" "ocp3-router-int-http" {
  load_balancer_arn = aws_lb.ocp3-router-int.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp3-router-int-http.arn
  }
}

resource "aws_lb_listener" "ocp3-router-int-https" {
  load_balancer_arn = aws_lb.ocp3-router-int.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ocp3-router-int-https.arn
  }
}

resource "aws_lb_target_group" "ocp3-router-int-http" {
  name        = var.lb_target_group_name_router_int_http
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.lb_target_group_name_router_int_http
    }
  )
}

resource "aws_lb_target_group" "ocp3-router-int-https" {
  name        = var.lb_target_group_name_router_int_https
  port        = 443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.lb_target_group_name_router_int_https
    }
  )
}

resource "aws_lb_target_group_attachment" "ocp3-router-int-http" {
  count = length(var.ocp3_router_int_instances) > 0 ? length(var.ocp3_router_int_instances) : 0

  target_group_arn = aws_lb_target_group.ocp3-router-int-http.arn
  target_id        = element(aws_instance.ocp3_router_int[*].private_ip, count.index)
  port             = 80
}

resource "aws_lb_target_group_attachment" "ocp3-router-int-https" {
  count = length(var.ocp3_router_int_instances) > 0 ? length(var.ocp3_router_int_instances) : 0

  target_group_arn = aws_lb_target_group.ocp3-router-int-https.arn
  target_id        = element(aws_instance.ocp3_router_int[*].private_ip, count.index)
  port             = 443
}
