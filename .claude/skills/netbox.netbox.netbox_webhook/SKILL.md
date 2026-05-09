---
name: netbox.netbox.netbox_webhook
description: >-
  Creates, updates or deletes webhook configuration within NetBox
  Use when managing netbox webhook resources via API with Ansible.
---

# netbox.netbox.netbox_webhook

Creates, updates or deletes webhook configuration within NetBox

## When to Use This Skill

Use the `netbox.netbox.netbox_webhook` Ansible module when you need to manage netbox webhook resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `data` | dict | yes | - | Defines the custom field |
| `netbox_token` | str | yes | - | The NetBox API token. |
| `netbox_url` | str | yes | - | The URL of the NetBox instance. Must be accessible by the Ansible control host. |
| `cert` | raw | no | - | Certificate path |
| `headers` | dict | no | - | Dictionary of headers to be passed to the NetBox API. |
| `query_params` | list | no | - | This can be used to override the specified values in ALLOWED_QUERY_PARAMS that are defined in plugins/module_utils/netbox_utils.py and provides control to users on what may make an object unique in their environment. |
| `state` | str | no | present | The state of the object. |
| `validate_certs` | raw | no | True | If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using a self-signed certificates. |
### Parameter Choices

- **state**: present, absent

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible localhost -m netbox.netbox.netbox_webhook -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m netbox.netbox.netbox_webhook -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --check --diff

# Apply the change
ansible localhost -m netbox.netbox.netbox_webhook -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: "Test NetBox webhook module"
  connection: local
  hosts: localhost
  tasks:
    - name: Create a webhook
      netbox_webhook:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          content_types:
            - dcim.device
          name: Example Webhook
          type_create: true
          payload_url: https://payload.url/
          body_template: !unsafe >-
            {{ data }}

    - name: Update the webhook to run on delete
      netbox_webhook:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Example Webhook
          type_create: true
          type_delete: true
          payload_url: https://payload.url/
          body_template: !unsafe >-
            {{ data }}

    - name: Delete the webhook
      netbox_webhook:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Example Webhook
          type_create: true
          type_delete: true
          payload_url: https://payload.url/
          body_template: !unsafe >-
            {{ data }}
        state: absent
```

## Key Flags

| Flag | Purpose |
|------|---------|
| `--check` | Dry-run mode -- shows what **would** change without applying |
| `--diff` | Shows detailed before/after differences |
| `-i <path>` | Specify inventory file (see Inventory section below) |
| `-l <pattern>` | Limit to specific hosts within a group |
| `-c local` | Use local connection (no SSH) |

## JSON Output

To get structured JSON output for programmatic parsing:

```bash
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m netbox.netbox.netbox_webhook -a "<args>" -c local
```

Or set `stdout_callback = json` in your `ansible.cfg`.

## Safety

- **Always dry-run first**: Use `--check --diff` before applying destructive changes
- **API credentials**: This module communicates with an external API. Keep tokens and URLs out of version control -- use environment variables or Ansible vault.
- **Idempotency**: This module is idempotent -- running it multiple times with the same arguments produces the same result

## Inventory

When using this module from a different location than the project root:

- Specify inventory explicitly: `-i /path/to/inventory.yml`
- Set environment variable: `export ANSIBLE_INVENTORY=/path/to/inventory.yml`
- Use Ansible's default: `/etc/ansible/hosts`
- Target a single host directly: `ansible <hostname>, -m netbox.netbox.netbox_webhook -a "..."` (note the trailing comma)
