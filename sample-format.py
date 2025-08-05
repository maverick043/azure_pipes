import yaml

# Example values (you need to define B, C, nodes earlier)
B = 1
C = 1
nodes = [
    {
        "node": {
            "name": "x1",
            "network_interfaces": [
                {
                    "network_interface": {
                        "name": "net0",
                        "network": "platoon3",
                        "ip_address": "192.168.1.10"
                    }
                }
            ]
        }
    },
    {
        "node": {
            "name": "y1",
            "network_interfaces": [
                {
                    "network_interface": {
                        "name": "net0",
                        "network": "platoon3",
                        "ip_address": "192.168.1.11"
                    }
                }
            ]
        }
    }
]

# Build the topology dictionary
topology = {
    "companies": [
        {
            "company": {
                "name": f"company{B}",
                "platoons": [
                    {
                        "platoon": {
                            "name": f"platoon{C}",
                            "nodes": nodes
                        }
                    }
                ]
            }
        }
    ]
}

# Write YAML file
with open("topology.yaml", "w") as file:
    yaml.dump(topology, file, default_flow_style=False, sort_keys=False, indent=2)
