########################################
# autoinstall OCP3 if enabled

resource "null_resource" "ocp3_auto_install" {
  count = var.ocp3_auto_install && length(var.ocp3_admin_instances) > 0 ? length(var.ocp3_admin_instances) : 0

  triggers = {
    always_run   = timestamp()
    host         = element(aws_instance.ocp3_admin.*.private_ip, count.index)
    ssh_username = var.ssh_username
    private_key  = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
  }

  provisioner "remote-exec" {
    inline = [
      "/home/ec2-user/openshift_install/run_auto_install.sh"
    ]

    connection {
      type        = "ssh"
      host        = self.triggers.host
      user        = self.triggers.ssh_username
      private_key = self.triggers.private_key
      insecure    = true
    }
  }

  depends_on = [
    aws_instance.ocp3_master,
    aws_instance.ocp3_router_int,
    aws_instance.ocp3_router_ext,
    aws_instance.ocp3_compute,
    aws_instance.ocp3_infra,
    aws_efs_file_system.ocp3_efs_persistent_vols_share,
    aws_efs_mount_target.ocp3_efs_persistent_vols_share,
    aws_efs_access_point.ocp3_efs_persistent_vols_share,
    aws_lb.ocp3-master-api,
    aws_lb_listener.ocp3-master-api,
    aws_lb_target_group.ocp3-master-api,
    aws_lb_target_group_attachment.ocp3-master-api,   
    aws_lb.ocp3-router-int,    
    aws_lb_listener.ocp3-router-int-http,
    aws_lb_listener.ocp3-router-int-https,
    aws_lb_target_group.ocp3-router-int-http,
    aws_lb_target_group.ocp3-router-int-https,
    aws_lb_target_group_attachment.ocp3-router-int-http,
    aws_lb_target_group_attachment.ocp3-router-int-https,   
    aws_route53_zone.ocp3,
    aws_route53_zone.ocp3_apps,
    aws_route53_record.ocp3_master_api_dns,
    aws_route53_record.ocp3_router_wildcard_dns,
    aws_route53_record.ocp3_master_node_dns,
    aws_route53_record.ocp3_router_int_node_dns,
    aws_route53_record.ocp3_router_ext_node_dns,
    aws_route53_record.ocp3_compute_node_dns,
    aws_route53_record.ocp3_infra_node_dns,
    aws_route53_record.ocp3_admin_node_dns,
    aws_s3_bucket.ocp3_registry_bucket,
    aws_s3_bucket_public_access_block.ocp3_registry_bucket_access,
    null_resource.cp_id_rsa,
    null_resource.cp_openshift_install_dir,
  ]
}
