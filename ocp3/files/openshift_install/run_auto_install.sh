#!/bin/bash

state_file_abs_path="/home/ec2-user/.ocp3_autoinstall_executed"
log_dir="/home/ec2-user/openshift_install/logs"

if [ ! -e $state_file_abs_path ]; then
  echo $(date) > $state_file_abs_path
  echo 
  echo "OCP3 auto installation will be started."
  echo

  if [ ! -e $log_dir ]; then
    mkdir $log_dir
    chmod 755 $log_dir
  fi

  cd /home/ec2-user/openshift_install/install/

  echo "#####################################################################"
  echo " Execute custom playbook pre_install_ocp3.yml"
  echo "#####################################################################"
  echo
  ansible-playbook -i ../global/hosts playbooks/pre_install_ocp3.yml | tee -a $log_dir/pre_install_ocp3.log
  echo 

  cd /usr/share/ansible/openshift-ansible/

  echo "#####################################################################"
  echo " Execute OCP installer playbook prerequisites.yml"
  echo "#####################################################################"
  echo
  ansible-playbook -i /home/ec2-user/openshift_install/install/config/openshift_inventory playbooks/prerequisites.yml | tee -a $log_dir/prerequisites.log
  echo

  echo "#####################################################################"
  echo " Execute OCP installer playbook deploy_cluster.yml"
  echo "#####################################################################"
  echo
  ansible-playbook -i /home/ec2-user/openshift_install/install/config/openshift_inventory playbooks/deploy_cluster.yml | tee -a $log_dir/deploy_cluster.log
  echo

  echo "####################################################################"
  echo "Starting OCP installer playbook openshift-provisioners/config.yml"
  echo "####################################################################"
  echo 
  ansible-playbook -i /home/ec2-user/openshift_install/install/config/openshift_inventory playbooks/openshift-provisioners/config.yml | tee -a $log_dir/provisioners_config.log
  echo

  cd /home/ec2-user/openshift_install/install/

  echo "####################################################################"
  echo " Execute custom playbook post_install_ocp3.yml"
  echo "####################################################################"
  echo 
  ansible-playbook -i ../global/hosts playbooks/post_install_ocp3.yml | tee -a $log_dir/post_install_ocp3.log
  echo
else
  echo "Skip OCP3 auto installation because it seems that OCP3 is already installed."
fi
