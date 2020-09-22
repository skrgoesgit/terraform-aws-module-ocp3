###################################################
# EC2 - OpenShift Admin

resource "aws_instance" "ocp3_admin" {
  count                  = length(var.ocp3_admin_instances)
  ami                    = var.admin_node_base_ami_id
  instance_type          = var.admin_node_instance_type
  subnet_id              = element(var.ocp3_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.sg_openshift_admin.id]
  iam_instance_profile   = var.iam_instance_role_name
  key_name               = var.ssh_keypair_name

  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_admin_instances[count.index]
    },
  )

  lifecycle {
    ignore_changes = [
      ebs_block_device,
    ]
  }

  depends_on = [
    aws_iam_instance_profile.profile
  ]
}
