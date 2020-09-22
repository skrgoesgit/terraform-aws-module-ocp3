###################################################
# Security Groups

########################################
# sg_openshift_efs

resource "aws_security_group" "sg_openshift_efs" {
  name        = var.ocp3_efs_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
       "Name" = var.ocp3_efs_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_efs_rule_ingress_allow_nfs_from_node" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_node.id
  security_group_id        = aws_security_group.sg_openshift_efs.id
}

resource "aws_security_group_rule" "sg_openshift_efs_rule_ingress_allow_nfs_from_infra" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_infra.id
  security_group_id        = aws_security_group.sg_openshift_efs.id
}

resource "aws_security_group_rule" "sg_openshift_efs_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_efs.id
}

########################################
# sg_openshift_admin

resource "aws_security_group" "sg_openshift_admin" {
  name        = var.ocp3_admin_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
       "Name" = var.ocp3_admin_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_admin_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_admin.id
}

resource "aws_security_group_rule" "sg_openshift_admin_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_admin.id
}

########################################
# sg_openshift_master

resource "aws_security_group" "sg_openshift_master" {
  name        = var.ocp3_master_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
       "Name" = var.ocp3_master_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_master_rule_ingress_allow_all_to_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.sg_openshift_master.id
}

resource "aws_security_group_rule" "sg_openshift_master_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_admin.id
  security_group_id        = aws_security_group.sg_openshift_master.id
}

resource "aws_security_group_rule" "sg_openshift_master_rule_ingress_allow_all_from_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_node.id
  security_group_id        = aws_security_group.sg_openshift_master.id
}

resource "aws_security_group_rule" "sg_openshift_master_rule_ingress_allow_all_from_infra" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_infra.id
  security_group_id        = aws_security_group.sg_openshift_master.id
}

resource "aws_security_group_rule" "sg_openshift_master_rule_ingress_allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_master.id
}

resource "aws_security_group_rule" "sg_openshift_master_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_master.id
}

########################################
# sg_openshift_node

resource "aws_security_group" "sg_openshift_node" {
  name        = var.ocp3_node_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_node_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_all_to_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_admin.id
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_all_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_master.id
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_all_from_infra" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_infra.id
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_all_from_router_int" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_router_int.id
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_ingress_allow_all_from_router_ext" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_router_ext.id
  security_group_id        = aws_security_group.sg_openshift_node.id
}

resource "aws_security_group_rule" "sg_openshift_node_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_node.id
}

########################################
# sg_openshift_infra

resource "aws_security_group" "sg_openshift_infra" {
  name        = var.ocp3_infra_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_infra_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_all_to_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_admin.id
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_all_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_master.id
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_all_from_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_node.id
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_all_from_router_int" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_router_int.id
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_ingress_allow_all_from_router_ext" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_router_ext.id
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

resource "aws_security_group_rule" "sg_openshift_infra_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_infra.id
}

########################################
# sg_openshift_router_int

resource "aws_security_group" "sg_openshift_router_int" {
  name        = var.ocp3_router_int_secgrp_name
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_router_int_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_all_to_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_admin.id
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_all_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_master.id
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_all_from_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_node.id
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_all_from_infra" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_infra.id
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_ingress_allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}

resource "aws_security_group_rule" "sg_openshift_router_int_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_int.id
}


########################################
# sg_openshift_router_ext

resource "aws_security_group" "sg_openshift_router_ext" {
  name        = var.ocp3_router_ext_secgrp_name
  vpc_id      = var.vpc_id
  
  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_router_ext_secgrp_name
    }
  )
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_all_to_itself" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  self                     = true
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_openshift_admin.id
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_all_from_master" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_master.id
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_all_from_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_node.id
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_all_from_infra" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.sg_openshift_infra.id
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_ingress_allow_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}

resource "aws_security_group_rule" "sg_openshift_router_ext_rule_egress_allow_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = ["0.0.0.0/0"]
  security_group_id        = aws_security_group.sg_openshift_router_ext.id
}
