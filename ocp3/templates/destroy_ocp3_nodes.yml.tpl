- name: OpenShift Node Destruction
  hosts: openshift
  become: yes
  gather_facts: yes
  tasks:
    - name: Unregister subscribed systems
      redhat_subscription:
        state: absent
        username: ${rhsm_user}
        password: ${rhsm_pw}
      tags: unsubscribe_systems
