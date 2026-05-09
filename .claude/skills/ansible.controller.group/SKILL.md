---
name: ansible.controller.group
description: >-
  create, update, or destroy Automation Platform Controller group.
  Use when managing group resources on remote hosts via Ansible.
---

# ansible.controller.group

create, update, or destroy Automation Platform Controller group.

## When to Use This Skill

Use the `ansible.controller.group` Ansible module when you need to manage group on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `inventory` | str | yes | - | Inventory name, ID, or named URL that the group should be made a member of. |
| `name` | str | yes | - | The name to use for the group. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `children` | list | no | - | List of groups names, IDs, or named URLs that should be nested inside in this group. |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `description` | str | no | - | The description to use for the group. |
| `hosts` | list | no | - | List of host names, IDs, or named URLs that should be put in this group. |
| `new_name` | str | no | - | A new name for this group (for renaming) |
| `preserve_existing_children` | bool | no | False | Provide option (False by default) to preserves existing children in an existing group. |
| `preserve_existing_hosts` | bool | no | False | Provide option (False by default) to preserves existing hosts in an existing group. |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `state` | str | no | present | Desired state of the resource. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
| `variables` | dict | no | - | Variables to use for the group. |
### Parameter Choices

- **state**: present, absent, exists

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.group -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.group -a "inventory=Local Inventory name=localhost" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.group -a "inventory=Local Inventory name=localhost" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Add group
  group:
    name: localhost
    description: "Local Host Group"
    inventory: "Local Inventory"
    state: present
    controller_config_file: "~/tower_cli.cfg"

- name: Add group
  group:
    name: Cities
    description: "Local Host Group"
    inventory: Default Inventory
    hosts:
      - fda
    children:
      - NewYork
    preserve_existing_hosts: true
    preserve_existing_children: true
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.group -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.group -a "..."` (note the trailing comma)
