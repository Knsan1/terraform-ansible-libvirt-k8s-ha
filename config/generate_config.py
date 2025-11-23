import yaml
from pathlib import Path

# --- Configuration Constants ---
GATEWAY = "192.168.1.1"
DNS = "8.8.8.8"

# --- Load Node Configuration ---
# Assuming 'node-config.yaml' contains a list of masters and workers,
# and masters is ordered (e.g., master-1, master-2, master-3)
try:
    with open("node-config.yaml") as f:
        config = yaml.safe_load(f)
except FileNotFoundError:
    print("Error: 'node-config.yaml' not found. Cannot proceed.")
    exit(1)

terraform_masters = {}
terraform_workers = {}

# --- Initialize Ansible Inventory Structure ---
ansible_inventory = {
    "all": {
        "children": {
            "masters": {
                "hosts": {},
                # ADDED: Group vars for SSH
                "vars": {
                    "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
                }
            },
            "workers": {
                "hosts": {},
                # ADDED: Group vars for SSH
                "vars": {
                    "ansible_ssh_common_args": "-o StrictHostKeyChecking=no"
                }
            }
        }
    }
}

def make_hostname(name, role):
    """Generates a consistent hostname format."""
    return f"KUBE-{role[:-1].upper()}-TERRAFORM-{name.split('-')[-1]}"

# --- Process Masters ---
for i, master in enumerate(config.get("masters", [])):
    name, ip = master["name"], master["ip"]

    # LOGIC FOR NEW INVENTORY FIELDS (Based on iteration index i)
    # master-1 (i=0) gets the highest priority (100) and state MASTER
    priority = 100 - (i * 10)
    state = "MASTER" if i == 0 else "BACKUP"

    # Terraform local variables population (unchanged)
    terraform_masters[name] = {
        "hostname": make_hostname(name, "masters"),
        "vm_name": name,
        "ip_address": ip,
        "gateway": GATEWAY,
        "dns": DNS
    }

    # Ansible Inventory population
    host_vars = {
        "ansible_host": ip,
        "ansible_user": name,
        "node_priority": priority, # ADDED
        "node_state": state,       # ADDED
    }

    if master.get("bootstrap", False):
        host_vars["is_bootstrap"] = True

    ansible_inventory["all"]["children"]["masters"]["hosts"][name] = host_vars

# --- Process Workers ---
for worker in config.get("workers", []):
    name, ip = worker["name"], worker["ip"]

    # Terraform local variables population (unchanged)
    terraform_workers[name] = {
        "hostname": make_hostname(name, "workers"),
        "vm_name": name,
        "ip_address": ip,
        "gateway": GATEWAY,
        "dns": DNS
    }

    # Ansible Inventory population (unchanged besides initial structure)
    ansible_inventory["all"]["children"]["workers"]["hosts"][name] = {
        "ansible_host": ip,
        "ansible_user": name
    }


# --- Write Ansible Inventory File ---
inventory_path = Path("ansible/inventory/hosts.yaml")
inventory_path.parent.mkdir(parents=True, exist_ok=True)
with inventory_path.open("w") as f:
    # Use sort_keys=False to preserve the order of 'hosts' then 'vars'
    yaml.dump(ansible_inventory, f, default_flow_style=False, sort_keys=False)

# --- Write Terraform Locals File (Unchanged logic) ---
tf_path = Path("terraform/locals.tf")
tf_path.parent.mkdir(parents=True, exist_ok=True)
with tf_path.open("w") as f:
    f.write("locals {\n")
    f.write("  masters = {\n")
    for name, attrs in terraform_masters.items():
        f.write(f'    "{name}" = {{\n')
        for k, v in attrs.items():
            f.write(f'      {k} = "{v}"\n')
        f.write("    }\n")
    f.write("  }\n")

    f.write("  workers = {\n")
    for name, attrs in terraform_workers.items():
        f.write(f'    "{name}" = {{\n')
        for k, v in attrs.items():
            f.write(f'      {k} = "{v}"\n')
        f.write("    }\n")
    f.write("  }\n")
    f.write("}\n")