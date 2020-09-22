variable "bucket_name" {
  type = string
  default = "mist"
}
variable "vpc_id" {
  type = string
}

variable "ocp3_subnet_ids" {
  type = list(string)
}

variable "internal_subnet_ids" {
  type = list(string)
}

variable "cluster_node_base_ami_id" {
  type = string
}

variable "cluster_node_sysvol_snapshot_id" {
  type = string
}

variable "admin_node_base_ami_id" {
  type = string
}

variable "admin_node_instance_type" {
  type = string
}

variable "master_node_instance_type" {
  type = string
}

variable "router_node_instance_type" {
  type = string
}

variable "compute_node_instance_type" {
  type = string
}

variable "infra_node_instance_type" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "lb_name_master_api" {
  type = string
}

variable "lb_name_router_int" {
  type = string
}

variable "lb_target_group_name_master_api" {
  type = string
}

variable "lb_target_group_name_router_int_http" {
  type = string
}

variable "lb_target_group_name_router_int_https" {
  type = string
}

variable "lb_target_group_name_router_ext_http" {
  type = string
}

variable "lb_target_group_name_router_ext_https" {
  type = string
}

variable "r53_ocp_private_zone_name" {
  type = string
}

variable "r53_ocp_private_zone_comment" {
  type = string
}

variable "r53_ocp_apps_private_zone_name" {
  type = string
}

variable "r53_ocp_apps_private_zone_comment" {
  type = string
}

variable "ocp3_master_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-master01", "ec2-<region>-<az>-<environment>-ocp3-master02", "ec2-<region>-<az>-<environment>-ocp3-master03"]
}

variable "ocp3_router_int_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-router01", "ec2-<region>-<az>-<environment>-ocp3-router02", "ec2-<region>-<az>-<environment>-ocp3-router03"]
}

variable "ocp3_router_ext_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-router04", "ec2-<region>-<az>-<environment>-ocp3-router05", "ec2-<region>-<az>-<environment>-ocp3-router06"]
}

variable "ocp3_compute_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-compute01", "ec2-<region>-<az>-<environment>-ocp3-compute02", "ec2-<region>-<az>-<environment>-ocp3-compute03"]
}

variable "ocp3_infra_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-infra01", "ec2-<region>-<az>-<environment>-ocp3-infra02", "ec2-<region>-<az>-<environment>-ocp3-infra03"]
}

variable "ocp3_admin_instances" {
  type = list(string)
  default = ["ec2-<region>-<az>-<environment>-ocp3-admin"]
}

variable "ocp3_efs_secgrp_name" {
  type = string
}

variable "ocp3_admin_secgrp_name" {
  type = string
}

variable "ocp3_master_secgrp_name" {
  type = string
}

variable "ocp3_node_secgrp_name" {
  type = string
}

variable "ocp3_infra_secgrp_name" {
  type = string
}

variable "ocp3_router_int_secgrp_name" {
  type = string
}

variable "ocp3_cluster_id" {
  type = string
}

variable "ocp3_router_ext_secgrp_name" {
  type = string
}

variable "ocp3_auto_install" {
  type = bool
  default = false
}

variable "s3_registry_storage_bucket_name" {
  type = string
  default = ""
}

variable "s3_registry_storage_bucket_region" {
  type = string
  default = ""
}

variable "iam_instance_role_name" {
  type = string
  default = ""
}

variable "iam_instance_policy_s3_name" {
  type = string
  default = ""
}

variable "iam_instance_policy_ec2_name" {
  type = string
  default = ""
}

variable "aws_secret_name_sshkey" {
  type = string
  default = ""
}

variable "aws_secret_name_rhsm" {
  type = string
  default = ""
}

variable "aws_secret_name_ldap_cred" {
  type = string
  default = ""
}

variable "aws_secret_name_ldap_cert" {
  type = string
  default = ""
}

variable "aws_secret_name_cert_body" {
  type = string
  default = ""
}

variable "aws_secret_name_cert_ca_body" {
  type = string
  default = ""
}

variable "aws_secret_name_cert_private_key" {
  type = string
  default = ""
}

variable "efs_filesystem_name" {
  type = string
  default = ""
}

variable "efs_filesystem_region" {
  type = string
  default = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
