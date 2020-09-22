oreg_auth_user: ${oreg_user}
oreg_auth_password: ${oreg_pw}

openshift_master_identity_providers:
  - name: ldap_auth
    kind: LDAPPasswordIdentityProvider
    login: true
    challenge: true
    attributes:
      id:
        - sAMAccountName
      email:
        - mail
      name:
        - displayName
    bindDN: ${ldap_bind_user}
    bindPassword: ${ldap_bind_pw}
    insecure: false
    ca: ldap_auth_ldap_ca.crt
    url: "${ldap_url}/${ldap_base_dn}?sAMAccountName?sub?"

openshift_master_ldap_ca_file: /home/ec2-user/openshift_install/install/config/ldaps_ca_cert.pem

openshift_node_groups:
  - name: node-config-master
    labels:
      - 'node-role.kubernetes.io/master=true'
    edits: []
  - name: node-config-infra
    labels:
      - 'node-role.kubernetes.io/infra=true'
    edits: []
  - name: node-config-compute
    labels:
      - 'node-role.kubernetes.io/compute=true'
    edits: []
  - name: node-config-router-int
    labels:
      - 'node-role.kubernetes.io/router_int=true'
    edits: []
  - name: node-config-router-ext
    labels:
      - 'node-role.kubernetes.io/router_ext=true'
    edits: []
