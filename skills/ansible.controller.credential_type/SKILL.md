---
name: ansible.controller.credential_type
description: >-
  Create, update, or destroy custom Automation Platform Controller credential type.
  Use when managing credential type resources on remote hosts via Ansible.
---

# ansible.controller.credential_type

Create, update, or destroy custom Automation Platform Controller credential type.

## When to Use This Skill

Use the `ansible.controller.credential_type` Ansible module when you need to manage credential type on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | str | yes | - | The name of the credential type. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `description` | str | no | - | The description of the credential type to give more detail about it. |
| `injectors` | dict | no | - | Enter injectors using either JSON or YAML syntax. Refer to the Automation Platform Controller documentation for example syntax. |
| `inputs` | dict | no | - | Enter inputs using either JSON or YAML syntax. Refer to the Automation Platform Controller documentation for example syntax. |
| `kind` | str | no | - | The type of credential type being added. Note that only cloud and net can be used for creating credential types. Refer to the Ansible for more information. |
| `new_name` | str | no | - | Setting this option will change the existing name (looked up via the name field. |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `state` | str | no | present | Desired state of the resource. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
### Parameter Choices

- **kind**: ssh, vault, net, scm, cloud, insights
- **state**: present, absent, exists

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.credential_type -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.credential_type -a "name=Nexus" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.credential_type -a "name=Nexus" -b --diff
```

### Examples from Ansible Documentation

```yaml
- credential_type:
    name: Nexus
    description: Credentials type for Nexus
    kind: cloud
    inputs: "{{ lookup('file', 'credential_inputs_nexus.json') }}"
    injectors: {'extra_vars': {'nexus_credential': 'test' }}
    state: present
    validate_certs: false

- credential_type:
    name: Nexus
    state: absent
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `-b` | Run with sudo/become (required for most system changes) |
| `--check` | Dry-run mode -- shows what **would** change without applying |
| `--diff` | Shows detailed before/after differences |
| `-i <path>` | Specify inventory file (see Inventory section below) |
| `-l <pattern>` | Limit to specific hosts within a group |

## JSON Output

To get structured JSON output for programmatic parsing:

```bash
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.credential_type -a "<args>" -b
```

Or set `stdout_callback = json` in your `ansible.cfg`.

## Safety

- **Always dry-run first**: Use `--check --diff` before applying destructive changes
- **Become/sudo**: Most system-level modules require `-b`. Check the parameters above for guidance.
- **Idempotency**: This module is idempotent -- running it multiple times with the same arguments produces the same result

## Inventory

When using this module from a different location than the project root:

- Specify inventory explicitly: `-i /path/to/inventory.yml`
- Set environment variable: `export ANSIBLE_INVENTORY=/path/to/inventory.yml`
- Use Ansible's default: `/etc/ansible/hosts`
- Target a single host directly: `ansible <hostname>, -m ansible.controller.credential_type -a "..."` (note the trailing comma)
