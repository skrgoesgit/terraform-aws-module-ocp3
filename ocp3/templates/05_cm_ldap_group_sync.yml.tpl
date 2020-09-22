apiVersion: v1
data:
  ldap-sync.yml: "apiVersion: v1\nkind: LDAPSyncConfig\nurl: ${ldap_url}\nbindDN:
    ${ldap_bind_user}\nbindPassword:
    ${ldap_bind_pw}\ninsecure: false\naugmentedActiveDirectory:\n
    \ groupsQuery:\n    derefAliases: never\n    pagesize: 0\n  groupUIDAttribute:
    dn\n  groupNameAttributes: [ cn ]\n  groupMembershipAttributes: [ member ]\n  usersQuery:\n
    \   derefAliases: never\n    baseDN: ${ldap_base_dn}\n    filter:
    (objectClass=user)\n    scope: sub \n    pagesize: 0\n  userUIDAttribute: dn\n
    \ userNameAttributes: [ sAMAccountName ]\n  groupMembershipAttributes: [ \"memberOf:1.2.840.113556.1.4.1941:\"
    ]\n  tolerateMemberNotFoundErrors: false\n  tolerateMemberOutOfScopeErrors: false\n"
  whitelist.txt: |-
    ${ldap_cn_ocp_admin_group}
    ${ldap_cn_ocp_user_group}
kind: ConfigMap
metadata:
  name: ldap-sync-config

# vi: filetype=yaml
