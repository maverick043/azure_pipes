import yaml

def generate_topology(node_count):
    nodes = []
    base_ip = [192, 168, 1, 10]

    for i in range(node_count):
        node_name = f"node{i+1}"
        ip = ".".join(map(str, base_ip))
        node = {
            "node": {
                "name": node_name,
                "network_interfaces": [
                    {
                        "network_interface": {
                            "name": "net0",
                            "network": "platoon3",
                            "ip_address": ip
                        }
                    }
                ]
            }
        }
        nodes.append(node)

        # Increment IP
        base_ip[3] += 1
        if base_ip[3] > 254:
            base_ip[3] = 1
            base_ip[2] += 1

    yaml_structure = {
        "companies": [
            {
                "company": {
                    "name": "company1",
                    "platoons": [
                        {
                            "platoon": {
                                "name": "platoon1",
                                "nodes": nodes
                            }
                        }
                    ]
                }
            }
        ]
    }

    return yaml_structure

# Generate YAML for 100 nodes
topology_yaml = generate_topology(100)

# Save to file
with open("generated_topology.yaml", "w") as f:
    yaml.dump(topology_yaml, f, sort_keys=False)
