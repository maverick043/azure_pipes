import yaml

with open("maas_vm.yaml") as f:
    config = yaml.safe_load(f)

vm = config["vm"]

tf = f"""
resource "maas_instance" "{vm['name']}" {{
  name   = "{vm['name']}"
  cpu    = {vm['cpu']}
  memory = {vm['memory']}
  disk   = {vm['disk']}

  network_interface {{
    name = "{vm['network'][0]['name']}"
    mode = "{vm['network'][0]['mode']}"
  }}

  user_data = <<EOF
#cloud-config
users:
  - name: {vm['user']['name']}
    ssh-authorized-keys:
      - {vm['user']['ssh_key']}
EOF
}}
"""

with open("main.tf", "w") as out:
    out.write(tf)
