---
name: ansible.controller.inventory
description: >-
  create, update, or destroy Automation Platform Controller inventory.
  Use when managing inventory resources on remote hosts via Ansible.
---

# ansible.controller.inventory

create, update, or destroy Automation Platform Controller inventory.

## When to Use This Skill

Use the `ansible.controller.inventory` Ansible module when you need to manage inventory on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | str | yes | - | The name to use for the inventory. |
| `organization` | str | yes | - | Organization name, ID, or named URL the inventory belongs to. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `copy_from` | str | no | - | Name or id to copy the inventory from. This will copy an existing inventory and change any parameters supplied. The new inventory name will be the one provided in the name parameter. The organization parameter is not used in this, to facilitate copy from one organization to another. Provide the id or use the lookup plugin to provide the id if multiple inventories share the same name. |
| `description` | str | no | - | The description to use for the inventory. |
| `host_filter` | str | no | - | The host_filter field. Only useful when C(kind=smart). |
| `input_inventories` | list | no | - | List of Inventory names, IDs, or named URLs to use as input for Constructed Inventory. |
| `instance_groups` | list | no | - | list of Instance Group names, IDs, or named URLs for this Organization to run on. |
| `kind` | str | no | - | The kind field. Cannot be modified after created. |
| `new_name` | str | no | - | Setting this option will change the existing name (looked up via the name field. |
| `prevent_instance_group_fallback` | bool | no | - | Prevent falling back to instance groups set on the organization |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `state` | str | no | present | Desired state of the resource. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
| `variables` | dict | no | - | Inventory variables. |
### Parameter Choices

- **kind**: , smart, constructed
- **state**: present, absent, exists

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.inventory -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.inventory -a "name=Foo Inventory organization=Bar Org" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.inventory -a "name=Foo Inventory organization=Bar Org" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Add inventory
  inventory:
    name: "Foo Inventory"
    description: "Our Foo Cloud Servers"
    organization: "Bar Org"
    state: present
    controller_config_file: "~/tower_cli.cfg"

- name: Copy inventory
  inventory:
    name: Copy Foo Inventory
    copy_from: Default Inventory
    description: "Our Foo Cloud Servers"
    organization: Foo
    state: present

# You can create and modify constructed inventories by creating an inventory
# of kind "constructed" and then editing the automatically generated inventory
# source for that inventory.
- name: Add constructed inventory with two existing input inventories
  inventory:
    name: My Constructed Inventory
    organization: Default
    kind: constructed
    input_inventories:
      - "West Datacenter"
      - "East Datacenter"

- name: Edit the constructed inventory source
  inventory_source:
    # The constructed inventory source will always be in the format:
    # "Auto-created source for: <constructed inventory name>"
    name: "Auto-created source for: My Constructed Inventory"
    inventory: My Constructed Inventory
    limit: host3,host4,host6
    source_vars:
      plugin: constructed
      strict: true
      use_vars_plugins: true
      groups:
        shutdown: resolved_state == "shutdown"
        shutdown_in_product_dev: resolved_state == "shutdown" and account_alias == "product_dev"
      compose:
        resolved_state: state | default("running")
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.inventory -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.inventory -a "..."` (note the trailing comma)
