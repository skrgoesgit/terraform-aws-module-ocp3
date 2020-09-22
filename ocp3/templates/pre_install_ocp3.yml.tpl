- name: OpenShift Node Preparation
  hosts: openshift
  become: yes
  gather_facts: yes
  tasks:
    - name: Register with Red Hat account and subscribe systems
      redhat_subscription:
        state: present
        username: ${rhsm_user}
        password: ${rhsm_pw}
        auto_attach: true
      tags: subscribe_systems

    - name: Enable Red Hat repos for RHEL7 and OpenShift 3.11
      rhsm_repository:
        name: "{{ item }}"
        state: enabled
      with_items:
        - rhel-7-server-rpms
        - rhel-7-server-extras-rpms
        - rhel-7-server-optional-rpms
        - rhel-7-server-ose-3.11-rpms
      tags: enable_repos

    - name: Update packages
      yum: name=* update_cache=yes state=latest
      tags: update_packages

    - name: Reboot system
      reboot:
        reboot_timeout: 300
      when: inventory_hostname not in groups['admin']
      tags: reboot

    - name: Install base packages
      yum:
        name:
          - wget
          - git
          - net-tools
          - bind-utils
          - yum-utils
          - iptables-services
          - bridge-utils
          - bash-completion
          - kexec-tools
          - sos
          - psacct
          - iotop
          - telnet
          - curl
          - nmap-ncat
          - perf
          - bcc
          - bcc-tools
          - lsof
          - sysstat
          - strace
        state: present
      when: inventory_hostname not in groups['admin']
      tags: install_base_packages

    - name: Install Docker
      yum: name=docker-1.13.1 state=present
      when: inventory_hostname not in groups['admin']
      tags: install_docker

    - name: Find device path of docker storage raw disk
      shell: lsblk -s -d | grep disk | awk '{print $1}'
      register: raw_disk_docker_storage
      when: inventory_hostname not in groups['admin']
      tags: find_dev_path_docker_storage

    - name: Configure docker-storage-setup script
      lineinfile:
        path: /etc/sysconfig/docker-storage-setup
        line: "{{ item }}"
        state: present
      with_items:
        - DEVS=/dev/{{ raw_disk_docker_storage.stdout }}
        - VG=vg_docker
      when: inventory_hostname not in groups['admin'] and raw_disk_docker_storage.stdout != ""
      tags: configure_docker_storage

    - name: Wipefs disk to prepare docker volume group creation
      command: /usr/sbin/wipefs -a /dev/{{ raw_disk_docker_storage.stdout }}
      when: inventory_hostname not in groups['admin'] and raw_disk_docker_storage.stdout != ""
      tags: wipe_raw_disk

    - name: Create docker volume group
      command: /bin/docker-storage-setup
      when: inventory_hostname not in groups['admin'] and raw_disk_docker_storage.stdout != ""
      tags: create_docker_vg

    - name: Configure docker
      lineinfile:
        path: /etc/sysconfig/docker
        regexp: '^OPTIONS='
        line: "OPTIONS=' --selinux-enabled --log-driver=json-file --log-opt max-size=1G --log-opt max-file=2 --signature-verification=False'"
        state: present
      when: inventory_hostname not in groups['admin']
      tags: configure_docker

    - name: Enable and start docker service
      systemd:
        name: docker
        enabled: yes
        state: started
      when: inventory_hostname not in groups['admin']
      tags: enable_docker
