###################################################
# Creation of local files + templating + transfer to remote hosts

########################################
# data sources to retrieve secret values

data "aws_secretsmanager_secret" "ocp3_secret_sshkey" {
  name = var.aws_secret_name_sshkey
}

data "aws_secretsmanager_secret_version" "ocp3_secret_sshkey" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_sshkey.id
}

data "aws_secretsmanager_secret" "ocp3_secret_rhsm" {
  name = var.aws_secret_name_rhsm
}

data "aws_secretsmanager_secret_version" "ocp3_secret_rhsm" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_rhsm.id
}

data "aws_secretsmanager_secret" "ocp3_secret_ldap_cred" {
  name = var.aws_secret_name_ldap_cred
}

data "aws_secretsmanager_secret_version" "ocp3_secret_ldap_cred" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_ldap_cred.id
}

data "aws_secretsmanager_secret" "ocp3_secret_cert_body" {
  name = var.aws_secret_name_cert_body
}

data "aws_secretsmanager_secret_version" "ocp3_secret_cert_body" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_cert_body.id
}

data "aws_secretsmanager_secret" "ocp3_secret_cert_ca_body" {
  name = var.aws_secret_name_cert_ca_body
}

data "aws_secretsmanager_secret_version" "ocp3_secret_cert_ca_body" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_cert_ca_body.id
}

data "aws_secretsmanager_secret" "ocp3_secret_cert_private_key" {
  name = var.aws_secret_name_cert_private_key
}

data "aws_secretsmanager_secret_version" "ocp3_secret_cert_private_key" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_cert_private_key.id
}

data "aws_secretsmanager_secret" "ocp3_secret_ldap_cert" {
  name = var.aws_secret_name_ldap_cert
}

data "aws_secretsmanager_secret_version" "ocp3_secret_ldap_cert" {
  secret_id = data.aws_secretsmanager_secret.ocp3_secret_ldap_cert.id
}

########################################
# create local files

resource "local_file" "hosts" {
  content  = templatefile("${path.module}/templates/hosts.tpl", {
               master_nodes     = aws_instance.ocp3_master.*.private_dns,
               router_int_nodes = aws_instance.ocp3_router_int.*.private_dns,
               router_ext_nodes = aws_instance.ocp3_router_ext.*.private_dns,
               compute_nodes    = aws_instance.ocp3_compute.*.private_dns,
               infra_nodes      = aws_instance.ocp3_infra.*.private_dns,
               admin_nodes      = aws_instance.ocp3_admin.*.private_dns,
               }
             )
  filename             = "${path.module}/files/openshift_install/global/hosts"
  file_permission      = "0644"
  directory_permission = "0755"

  depends_on = [
    aws_instance.ocp3_master,
    aws_instance.ocp3_compute,
    aws_instance.ocp3_router_int,
    aws_instance.ocp3_router_ext,
    aws_instance.ocp3_infra,
    aws_instance.ocp3_admin,
  ]
}

resource "local_file" "openshift_inventory" {
  content  = templatefile("${path.module}/templates/openshift_inventory.tpl", {
               master_nodes                      = aws_instance.ocp3_master.*.private_dns,
               router_int_nodes                  = aws_instance.ocp3_router_int.*.private_dns,
               router_ext_nodes                  = aws_instance.ocp3_router_ext.*.private_dns,
               compute_nodes                     = aws_instance.ocp3_compute.*.private_dns,
               infra_nodes                       = aws_instance.ocp3_infra.*.private_dns,
               admin_nodes                       = aws_instance.ocp3_admin.*.private_dns,
               ocp_private_zone                  = var.r53_ocp_private_zone_name,
               ocp_apps_private_zone             = var.r53_ocp_apps_private_zone_name,
               s3_registry_storage_bucket_name   = var.s3_registry_storage_bucket_name,
               s3_registry_storage_bucket_region = var.s3_registry_storage_bucket_region,
               openshift_cluster_id              = var.ocp3_cluster_id,
               efs_filesystem_id                 = element(split(".", aws_efs_file_system.ocp3_efs_persistent_vols_share.dns_name), 0),
               efs_filesystem_region             = var.efs_filesystem_region,
               docker_registry_replica_count     = length(aws_instance.ocp3_infra.*)
               }
             )
  filename             = "${path.module}/files/openshift_install/install/config/openshift_inventory"
  file_permission      = "0644"
  directory_permission = "0755"

  depends_on = [
    aws_instance.ocp3_master,
    aws_instance.ocp3_compute,
    aws_instance.ocp3_router_int,
    aws_instance.ocp3_router_ext,
    aws_instance.ocp3_infra,
    aws_instance.ocp3_admin,
    aws_efs_file_system.ocp3_efs_persistent_vols_share,
  ]
}

resource "local_file" "vars_yml" {
  content  = templatefile("${path.module}/templates/vars.yml.tpl", {
               oreg_user      = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["oreg_user"],
               oreg_pw        = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["oreg_pw"],
               ldap_bind_user = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["bind_user"],
               ldap_bind_pw   = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["bind_pw"],
               ldap_url       = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["url"],
               ldap_base_dn   = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["base_dn"],
               }
             )
  filename             = "${path.module}/files/openshift_install/install/config/group_vars/OSEv3/vars.yml"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "pre_install_ocp3_yml" {
  content  = templatefile("${path.module}/templates/pre_install_ocp3.yml.tpl", {
               rhsm_user = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["rhsm_user"],
               rhsm_pw   = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["rhsm_pw"],
               }
             )
  filename             = "${path.module}/files/openshift_install/install/playbooks/pre_install_ocp3.yml"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "post_install_ocp3_yml" {
  content  = templatefile("${path.module}/templates/post_install_ocp3.yml.tpl", {
               master_node             = aws_instance.ocp3_master[0].private_dns,
               compute_node            = aws_instance.ocp3_compute[0].private_dns,
               admin_node              = aws_instance.ocp3_admin[0].private_dns,
               efs_filesystem_dns_name = aws_efs_file_system.ocp3_efs_persistent_vols_share.dns_name,
               ldap_cn_ocp_admin_group = element(split("=", element(split(",", jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["cn_ocp_admin_group"]), 0)), 1),
               ldap_cn_ocp_user_group  = element(split("=", element(split(",", jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["cn_ocp_user_group"]), 0)), 1),
               } 
             )
  filename             = "${path.module}/files/openshift_install/install/playbooks/post_install_ocp3.yml"
  file_permission      = "0600"
  directory_permission = "0755"

  depends_on = [
    aws_instance.ocp3_master,
    aws_instance.ocp3_compute,
    aws_instance.ocp3_admin,
    aws_efs_file_system.ocp3_efs_persistent_vols_share,
  ]
}

resource "local_file" "fix_node_labels_sh" {
  content  = templatefile("${path.module}/templates/fix_node_labels.sh.tpl", {
               infra_nodes = aws_instance.ocp3_infra.*.private_dns,
               }
             )
  filename             = "${path.module}/files/openshift_install/install/scripts/fix_node_labels.sh"
  file_permission      = "0755"
  directory_permission = "0755"

  depends_on = [
    aws_instance.ocp3_infra,
  ]
}

resource "local_file" "cm_ldap_group_sync_yml" {
  content  = templatefile("${path.module}/templates/05_cm_ldap_group_sync.yml.tpl", {
               ldap_bind_user          = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["bind_user"],
               ldap_bind_pw            = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["bind_pw"],
               ldap_url                = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["url"],
               ldap_base_dn            = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["base_dn"],
               ldap_cn_ocp_admin_group = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["cn_ocp_admin_group"],
               ldap_cn_ocp_user_group  = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cred.secret_string)["cn_ocp_user_group"],
               }
             )
  filename             = "${path.module}/files/openshift_install/install/templates/05_cm_ldap_group_sync.yml"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "destroy_ocp3_nodes_yml" {
  content  = templatefile("${path.module}/templates/destroy_ocp3_nodes.yml.tpl", {
               rhsm_user = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["rhsm_user"],
               rhsm_pw   = jsondecode(data.aws_secretsmanager_secret_version.ocp3_secret_rhsm.secret_string)["rhsm_pw"],
               }
             )
  filename             = "${path.module}/files/openshift_install/uninstall/playbooks/destroy_ocp3_nodes.yml"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "id_rsa" {
  content = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
  filename             = "${path.module}/files/id_rsa"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "fx_cert_pem" {
  content = data.aws_secretsmanager_secret_version.ocp3_secret_cert_body.secret_string
  filename             = "${path.module}/files/openshift_install/install/config/fx_cert.pem"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "ca_pem" {
  content = data.aws_secretsmanager_secret_version.ocp3_secret_cert_ca_body.secret_string
  filename             = "${path.module}/files/openshift_install/install/config/ca.pem"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "fx_cert_key_pem" {
  content = data.aws_secretsmanager_secret_version.ocp3_secret_cert_private_key.secret_string
  filename             = "${path.module}/files/openshift_install/install/config/fx_cert_key.pem"
  file_permission      = "0600"
  directory_permission = "0755"
}

resource "local_file" "ldaps_ca_cert_pem" {
  content = data.aws_secretsmanager_secret_version.ocp3_secret_ldap_cert.secret_string
  filename             = "${path.module}/files/openshift_install/install/config/ldaps_ca_cert.pem"
  file_permission      = "0600"
  directory_permission = "0755"
}

########################################
# copy files to remote hosts

resource "null_resource" "cp_id_rsa" {
  count = length(var.ocp3_admin_instances)

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.module}/files/id_rsa"
    destination = "/home/ec2-user/.ssh/id_rsa"

    connection {
      type        = "ssh"
      host        = element(aws_instance.ocp3_admin.*.private_ip, count.index)
      user        = var.ssh_username
      private_key = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
      insecure    = true
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/.ssh/id_rsa",
    ]

    connection {
      type        = "ssh"
      host        = element(aws_instance.ocp3_admin.*.private_ip, count.index)
      user        = var.ssh_username
      private_key = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
      insecure    = true
    }
  }

  depends_on = [
    local_file.id_rsa,
    aws_instance.ocp3_admin,
  ]
}

resource "null_resource" "cp_openshift_install_dir" {
  count = length(var.ocp3_admin_instances)

  triggers = {
    always_run = timestamp()
  }

  provisioner "file" {
    source      = "${path.module}/files/openshift_install"
    destination = "/home/ec2-user"

    connection {
      type        = "ssh"
      host        = element(aws_instance.ocp3_admin.*.private_ip, count.index)
      user        = var.ssh_username
      private_key = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
      insecure    = true
    }
  }

  provisioner "remote-exec" {
    inline = [
      "find /home/ec2-user/openshift_install -type f -name '*.sh' | xargs chmod 750",
      "find /home/ec2-user/openshift_install -type f -name '*.yml' | xargs chmod 640",
      "find /home/ec2-user/openshift_install -type f -name '*.pem' | xargs chmod 640",
    ]
  
    connection {
      type        = "ssh"
      host        = element(aws_instance.ocp3_admin.*.private_ip, count.index)
      user        = var.ssh_username
      private_key = data.aws_secretsmanager_secret_version.ocp3_secret_sshkey.secret_string
      insecure    = true
    }
  }

  depends_on = [
    aws_instance.ocp3_admin,
    local_file.hosts,
    local_file.openshift_inventory,
    local_file.vars_yml,
    local_file.pre_install_ocp3_yml,
    local_file.post_install_ocp3_yml,
    local_file.fix_node_labels_sh,
    local_file.cm_ldap_group_sync_yml,
    local_file.destroy_ocp3_nodes_yml,
    local_file.fx_cert_pem,
    local_file.fx_cert_key_pem,
    local_file.ca_pem,
  ]
}
