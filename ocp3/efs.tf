###################################################
# EFS

data "aws_kms_key" "efs" {
  key_id = "alias/aws/elasticfilesystem"
}

resource "aws_efs_file_system" "ocp3_efs_persistent_vols_share" {
  creation_token = var.efs_filesystem_name
  encrypted      = true
  kms_key_id     = data.aws_kms_key.efs.arn

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.efs_filesystem_name
    }
  )
}

resource "aws_efs_mount_target" "ocp3_efs_persistent_vols_share" {
  count = length(var.internal_subnet_ids) > 0 ? length(var.internal_subnet_ids) : 0

  file_system_id  = aws_efs_file_system.ocp3_efs_persistent_vols_share.id
  subnet_id       = element(var.internal_subnet_ids, count.index)
  security_groups = [aws_security_group.sg_openshift_efs.id]
}

resource "aws_efs_access_point" "ocp3_efs_persistent_vols_share" {
  file_system_id = aws_efs_file_system.ocp3_efs_persistent_vols_share.id

  posix_user {
    uid = 65534
    gid = 65534
  }

  root_directory {
    path = "/data/persistentvolumes"

    creation_info {
      owner_uid   = 65534
      owner_gid   = 65534
      permissions = 0755
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = "/data/persistentvolumes"
    }
  )
}
