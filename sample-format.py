import yaml

# Custom Dumper to fix PyYAML's default bad indentation
class IndentDumper(yaml.SafeDumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(IndentDumper, self).increase_indent(flow, indentless=False)

# Example data
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

topology = {
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

# Write to YAML with correct indentation
with open("topology.yaml", "w") as f:
    yaml.dump(
        topology,
        f,
        Dumper=IndentDumper,
        default_flow_style=False,
        sort_keys=False,
        indent=2
    )
