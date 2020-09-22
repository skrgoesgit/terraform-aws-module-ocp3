[OSEv3:children]
masters
router_int
router_ext
compute
infra

############################################
# node definitions

[masters]
%{ for hostname in master_nodes ~}
${hostname}
%{ endfor ~}

[masters:vars]
openshift_node_group_name='node-config-master'

[etcd]

[etcd:children]
masters

[router_int]
%{ for hostname in router_int_nodes ~}
${hostname}
%{ endfor ~}

[router_int:vars]
openshift_node_group_name='node-config-router-int'

[router_ext]
%{ for hostname in router_ext_nodes ~}
${hostname}
%{ endfor ~}

[router_ext:vars]
openshift_node_group_name='node-config-router-ext'

[compute]
%{ for hostname in compute_nodes ~}
${hostname}
%{ endfor ~}

[compute:vars]
openshift_node_group_name='node-config-compute'

[infra]
%{ for hostname in infra_nodes ~}
${hostname}
%{ endfor ~}

[infra:vars]
openshift_node_group_name='node-config-infra'


[nodes]

[nodes:children]
masters
compute
router_int
router_ext
infra

############################################
# variable definitions


[OSEv3:vars]

# SSH options
ansible_ssh_user=ec2-user
ansible_become=true
#ansible_ssh_extra_args='-o StrictHostKeyChecking=no'

# OpenShift Health Checks
openshift_disable_check=docker_storage

# Only run the registry on nodes with the 'infra=true' label
openshift_hosted_registry_selector='node-role.kubernetes.io/infra=true'

# Run only one replica of the registry because of blockstorage
openshift_hosted_registry_replicas=3

openshift_deployment_type=openshift-enterprise
openshift_release=v3.11

# Don't install all examples
openshift_install_examples=false

# We use firewalld
os_firewall_use_firewalld=true

openshift_master_default_subdomain=${ocp_apps_private_zone}

# Networkpolicy network plugin
os_sdn_network_plugin_name=redhat/openshift-ovs-networkpolicy

# Native high availability cluster method with external load balancer
openshift_master_cluster_public_hostname=fx.${ocp_private_zone}
openshift_master_cluster_hostname=fx.${ocp_private_zone}
openshift_master_api_port=443
openshift_master_console_port=443
public_hostname=fx.${ocp_private_zone}

openshift_master_named_certificates=[{"certfile": "/home/ec2-user/openshift_install/install/config/fx_cert.pem", "keyfile": "/home/ec2-user/openshift_install/install/config/fx_cert_key.pem", "cafile": "/home/ec2-user/openshift_install/install/config/ca.pem", "names": ["fx.${ocp_private_zone}"]}]

openshift_master_overwrite_named_certificates=true

# NTP (ensured by AWS)
openshift_clock_enabled=false

# Only run routers on nodes with the 'router_int=true' label
openshift_router_selector='node-role.kubernetes.io/router_int=true'

# Set the default node selector to 'compute=true'
osm_default_node_selector='node-role.kubernetes.io/compute=true'

# Enable metrics on block storage
openshift_metrics_install_metrics=true
openshift_metrics_cassandra_storage_type=pv
openshift_metrics_cassandra_pvc_storage_class_name=ebs-block-storage
openshift_metrics_heapster_nodeselector={'node-role.kubernetes.io/infra': 'true'}
openshift_metrics_hawkular_nodeselector={'node-role.kubernetes.io/infra': 'true'}
openshift_metrics_cassandra_nodeselector={'node-role.kubernetes.io/infra': 'true'}

# Prometheus
openshift_cluster_monitoring_operator_prometheus_storage_enabled=true
openshift_cluster_monitoring_operator_prometheus_storage_class_name=ebs-block-storage
openshift_cluster_monitoring_operator_alertmanager_storage_class_name=ebs-block-storage

# Config for initial logging setup. Wont be used as logging_install is set to false.
openshift_logging_install_logging=true
openshift_logging_es_cluster_size=1
openshift_logging_use_ops=false
openshift_logging_kibana_hostname="kibana.${ocp_apps_private_zone}"
openshift_logging_eventrouter_nodeselector={"node-role.kubernetes.io/infra": "true"}
openshift_logging_curator_nodeselector={"node-role.kubernetes.io/infra": "true"}
openshift_logging_kibana_nodeselector={"node-role.kubernetes.io/infra": "true"}
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra": "true"}
openshift_logging_fluentd_nodeselector={"node-role.kubernetes.io/infra": "true"}

# Disable the Ansible Service Broker
ansible_service_broker_remove=true
ansible_service_broker_install=false

# Disable the Template Service Broker
template_service_broker_remove=true
template_service_broker_install=false

# Disable the Service Catalog
openshift_service_catalog_remove=true
openshift_enable_service_catalog=false

# Customize Docker logging options
openshift_docker_options=" --log-driver=json-file --log-opt max-size=1G --log-opt max-file=2"

# AWS EFS
openshift_provisioners_install_provisioners=True
openshift_provisioners_efs=True
openshift_provisioners_efs_fsid=${efs_filesystem_id}
openshift_provisioners_efs_region=${efs_filesystem_region}
openshift_provisioners_efs_aws_access_key_id=
openshift_provisioners_efs_aws_secret_access_key=
openshift_provisioners_efs_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_provisioners_efs_path=/data/persistentvolumes

# AWS S3 (storage internal docker registry)
openshift_cloudprovider_kind=aws
openshift_clusterid=${openshift_cluster_id}
openshift_hosted_manage_registry=true
openshift_hosted_registry_storage_kind=object
openshift_hosted_registry_storage_provider=s3
openshift_hosted_registry_storage_s3_bucket=${s3_registry_storage_bucket_name}
openshift_hosted_registry_storage_s3_region=${s3_registry_storage_bucket_region}
openshift_hosted_registry_storage_s3_regionendpoint=https://s3.${s3_registry_storage_bucket_region}.amazonaws.com
openshift_hosted_registry_storage_s3_chunksize=26214400
openshift_hosted_registry_storage_s3_rootdirectory=/registry
openshift_hosted_registry_storage_s3_encrypt=false
openshift_hosted_registry_storage_s3_kmskeyid=
openshift_hosted_registry_pullthrough=true
openshift_hosted_registry_acceptschema2=true
openshift_hosted_registry_enforcequota=true
openshift_hosted_registry_replicas=${docker_registry_replica_count}
