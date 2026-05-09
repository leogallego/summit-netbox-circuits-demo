---
name: netbox.netbox.netbox_site
description: >-
  Creates or removes sites from NetBox
  Use when managing netbox site resources via API with Ansible.
---

# netbox.netbox.netbox_site

Creates or removes sites from NetBox

## When to Use This Skill

Use the `netbox.netbox.netbox_site` Ansible module when you need to manage netbox site resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `data` | dict | yes | - | Defines the site configuration |
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
ansible localhost -m netbox.netbox.netbox_site -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m netbox.netbox.netbox_site -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --check --diff

# Apply the change
ansible localhost -m netbox.netbox.netbox_site -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: "Test NetBox site module"
  connection: local
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Create site within NetBox with only required information
      netbox.netbox.netbox_site:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test - Colorado
        state: present

    - name: Delete site within netbox
      netbox.netbox.netbox_site:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test - Colorado
        state: absent

    - name: Create site with all parameters
      netbox.netbox.netbox_site:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          name: Test - California
          status: Planned
          region: Test Region
          site_group: Test Site Group
          tenant: Test Tenant
          facility: EquinoxCA7
          asn: 65001
          time_zone: America/Los Angeles
          description: This is a test description
          physical_address: Hollywood, CA, 90210
          shipping_address: Hollywood, CA, 90210
          latitude: 10.100000
          longitude: 12.200000
          contact_name: Jenny
          contact_phone: 867-5309
          contact_email: jenny@changednumber.com
          slug: test-california
          comments: ### Placeholder
        state: present
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
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m netbox.netbox.netbox_site -a "<args>" -c local
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
- Target a single host directly: `ansible <hostname>, -m netbox.netbox.netbox_site -a "..."` (note the trailing comma)
