###################################################
# EC2 - OpenShift Router (internal access)

resource "aws_instance" "ocp3_router_int" {
  count                  = length(var.ocp3_router_int_instances)
  ami                    = var.cluster_node_base_ami_id
  instance_type          = var.router_node_instance_type
  subnet_id              = element(var.ocp3_subnet_ids, count.index)
  vpc_security_group_ids = [aws_security_group.sg_openshift_router_int.id]
  iam_instance_profile   = var.iam_instance_role_name
  key_name               = var.ssh_keypair_name

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp2"
    volume_size           = 60
    snapshot_id           = var.cluster_node_sysvol_snapshot_id
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp2"
    volume_size           = 40
    delete_on_termination = true
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.ocp3_router_int_instances[count.index]
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
