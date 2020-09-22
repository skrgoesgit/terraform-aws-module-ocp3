- name: OpenShift
  hosts: ${master_node}
  become: yes
  gather_facts: yes
  tasks:
    - name: Fetch KUBECONFIG file from master node
      fetch:
        src: /root/.kube/config
        dest: /home/ec2-user/.kube/config
        flat: yes
      tags: fetch_kubeconfig

- name: OpenShift
  hosts: ${compute_node}
  become: yes
  gather_facts: yes
  tasks:
    - name: Create directory on EFS share to be used as EFS accesspoint
      command: "{{ item }}"
      args:
        chdir: /
        warn: no
      with_items:
        - mount -t nfs ${efs_filesystem_dns_name}:/ /mnt
        - mkdir -p /mnt/data/persistentvolumes
        - chown -R nfsnobody.nfsnobody /mnt/data
        - umount /mnt
      tags: create_efs_directory

- name: OpenShift
  hosts: ${admin_node}
  become: no
  gather_facts: no
  tasks:
    - name: Set appropiate file permissions for KUBECONFIG file
      file:
        path: /home/ec2-user/.kube/config
        owner: ec2-user
        group: ec2-user
        mode: 0600
      tags: set_kubeconfig_file_permissions

    - name: Fix node labels (OCP3 ansible installer bug)
      shell: ./fix_node_labels.sh 2>&1 > fix_node_labels.log
      args:
        chdir: /home/ec2-user/openshift_install/install/scripts/
      tags: fix_node_labels

    - name: Create cluster-ops namespace
      k8s:
        name: cluster-ops
        api_version: v1
        kind: Namespace
        state: present
        validate_certs: no
      tags: create_cluster_ops_namespace

    - name: Create imagestream for ose-cli
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/01_is_ose_cli.yml
        namespace: cluster-ops
        state: present
        validate_certs: no
      tags: create_imagestream_ose_cli

    - name: Create serviceaccount ldap-group-syncer
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/02_sa_ldap_group_syncer.yml
        namespace: cluster-ops
        state: present
        validate_certs: no
      tags: create_serviceaccount_ldap_group_syncer

    - name: Create cluster role ldap-group-sync
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/03_cluster_role_ldap_group_sync.yml
        state: present
        validate_certs: no
      tags: create_cluster_role_ldap_group_sync

    - name: Create rolebinding ldap-group-sync
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/04_cluster_rolebinding_ldap_group_sync.yml
        state: present
        validate_certs: no
      tags: create_cluster_rolebinding_ldap_group_sync

    - name: Create configmap ldap-group-sync
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/05_cm_ldap_group_sync.yml
        namespace: cluster-ops
        state: present
        validate_certs: no
      tags: create_configmap_ldap_group_sync

    - name: Create cronjob ldap-group-sync
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/06_cj_ldap_group_sync.yml
        namespace: cluster-ops
        state: present
        validate_certs: no
      tags: create_cronjob_ldap_group_sync

    - name: Lets wait for the initial LDAP group sync (timeout 15 min)"
      shell: oc get jobs -n cluster-ops | grep ldap-group-sync | grep "1         1" | tail -1
      register: result
      until: result.stdout.find("ldap-group-sync") != -1
      ignore_errors: yes
      retries: 90
      delay: 10

    - name: Assign cluster role "cluster-admin" to group ${ldap_cn_ocp_admin_group}
      command: oc adm policy add-cluster-role-to-group cluster-admin ${ldap_cn_ocp_admin_group}
      args:
        chdir: /home/ec2-user
      ignore_errors: yes
      tags: assign_cluster_admin_role

    - name: Assign cluster role "cluster-user" to group ${ldap_cn_ocp_user_group}
      command: oc adm policy add-cluster-role-to-group cluster-user ${ldap_cn_ocp_user_group}
      args:
        chdir: /home/ec2-user
      tags: assign_cluster_user_role

    - name: Create storage class ebs-block-storage
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/07_storageclass_ebs.yml
        state: present
        validate_certs: no
      tags: create_storage_class_ebs

    - name: Create storage class efs-file-storage
      k8s:
        src: /home/ec2-user/openshift_install/install/templates/08_storageclass_efs.yml
        state: present
        validate_certs: no
      tags: create_storage_class_efs

    - name: Delete default storageclass gp2 (AWS default)
      command: oc delete storageclass gp2
      ignore_errors: yes
      args:
        chdir: /home/ec2-user
      tags: delete_storage_class_gp2
