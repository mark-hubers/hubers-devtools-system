# 📄 JSON & YAML Tools

## JSON (jq)

```bash
json file.json              # Pretty print
json-validate file.json     # Validate JSON
echo '{"a":1}' | json       # From stdin
```

## YAML (yq)

```bash
yaml file.yaml              # Pretty print
yaml-validate file.yaml     # Validate YAML
```

## Examples

```bash
# Pretty print API response
curl api.example.com | json

# Validate config
json-validate package.json

# Parse YAML
yaml config.yaml
```

## Installation

```bash
brew install jq yq
```

See [00-START-HERE.md](../00-START-HERE.md) for more utilities.
