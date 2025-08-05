import yaml

# Read messy or unindented YAML
with open("messy.yaml", "r") as f:
    try:
        data = yaml.safe_load(f)
    except yaml.YAMLError as exc:
        print("YAML parsing error:", exc)
        exit(1)

# Write it back with clean indentation
with open("fixed.yaml", "w") as f:
    yaml.dump(data, f, sort_keys=False, indent=2)
