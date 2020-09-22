[openshift:children]
master
router
compute
infra
admin

[master]
%{ for hostname in master_nodes ~}
${hostname}
%{ endfor ~}

[router]
%{ for hostname in router_int_nodes ~}
${hostname}
%{ endfor ~}
%{ for hostname in router_ext_nodes ~}
${hostname}
%{ endfor ~}

[compute]
%{ for hostname in compute_nodes ~}
${hostname}
%{ endfor ~}

[infra]
%{ for hostname in infra_nodes ~}
${hostname}
%{ endfor ~}

[admin]
%{ for hostname in admin_nodes ~}
${hostname}
%{ endfor ~}
