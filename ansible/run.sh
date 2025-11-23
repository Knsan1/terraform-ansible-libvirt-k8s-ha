ANSIBLE_HOST_KEY_CHECKING=False ansible -i inventory/hosts.yaml all -m ping
# 1–4: Run on all nodes
ansible-playbook -i inventory/hosts.yml playbooks/01-common.yml
ansible-playbook -i inventory/hosts.yml playbooks/02-containerd.yml
ansible-playbook -i inventory/hosts.yml playbooks/03-k8s-tools.yml
ansible-playbook -i inventory/hosts.yml playbooks/04-keepalived.yml --limit masters

# 5: Bootstrap first master (has is_bootstrap: true)
ansible-playbook -i inventory/hosts.yml playbooks/05-bootstrap.yml --limit master-1

# 6–7: Join others
bash join-controlplane.sh   # on master-2 and master-3
bash join-worker.sh         # on worker-1 and worker-2
