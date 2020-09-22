#!/bin/bash

echo "OCP3 destruction will be started."

cd /home/ec2-user/openshift_install/uninstall/
ansible-playbook -i ../global/hosts playbooks/destroy_ocp3_nodes.yml
