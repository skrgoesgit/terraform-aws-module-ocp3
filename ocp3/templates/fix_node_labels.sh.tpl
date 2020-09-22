#!/bin/bash

template_string='(%{ for hostname in infra_nodes ~}${hostname}|%{ endfor ~})'

template_string=$(echo $template_string | sed "s/|)$/)/")

for i in $(oc get nodes | awk '{print $1}' | grep -v NAME | egrep -v $template_string)
  do
    oc label node $i node-role.kubernetes.io/infra-
  done
