---
name: netbox.netbox.netbox_ip_address
description: >-
  Creates or removes IP addresses from NetBox
  Use when managing netbox ip address resources via API with Ansible.
---

# netbox.netbox.netbox_ip_address

Creates or removes IP addresses from NetBox

## When to Use This Skill

Use the `netbox.netbox.netbox_ip_address` Ansible module when you need to manage netbox ip address resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `data` | dict | yes | - | Defines the IP address configuration |
| `netbox_token` | str | yes | - | The NetBox API token. |
| `netbox_url` | str | yes | - | The URL of the NetBox instance. Must be accessible by the Ansible control host. |
| `cert` | raw | no | - | Certificate path |
| `headers` | dict | no | - | Dictionary of headers to be passed to the NetBox API. |
| `query_params` | list | no | - | This can be used to override the specified values in ALLOWED_QUERY_PARAMS that are defined in plugins/module_utils/netbox_utils.py and provides control to users on what may make an object unique in their environment. |
| `state` | str | no | present | Use C(present), C(new) or C(absent) for adding, force adding or removing.
C(present) will check if the IP is already created, and return it if
true. C(new) will force to create it anyway (useful for anycasts, for
example).
 |
| `validate_certs` | raw | no | True | If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using a self-signed certificates. |
### Parameter Choices

- **state**: absent, new, present

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible localhost -m netbox.netbox.netbox_ip_address -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m netbox.netbox.netbox_ip_address -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --check --diff

# Apply the change
ansible localhost -m netbox.netbox.netbox_ip_address -a "data=<data> netbox_token=thisIsMyToken netbox_url=http://netbox.local" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: "Test NetBox IP address module"
  connection: local
  hosts: localhost
  gather_facts: false

  tasks:
    - name: Create IP address within NetBox with only required information
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          address: 192.168.1.10
        state: present

    - name: Force to create (even if it already exists) the IP
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          address: 192.168.1.10
        state: new

    - name: Get a new available IP inside 192.168.1.0/24
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          prefix: 192.168.1.0/24
        state: new

    - name: Delete IP address within netbox
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          address: 192.168.1.10
        state: absent

    - name: Create IP address with several specified options
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          address: 192.168.1.20
          vrf: Test
          tenant: Test Tenant
          status: Reserved
          role: Loopback
          description: Test description
          tags:
            - Schnozzberry
        state: present

    - name: Create IP address and assign a nat_inside IP
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          address: 192.168.1.30
          vrf: Test
          nat_inside:
            address: 192.168.1.20
            vrf: Test
          interface:
            name: GigabitEthernet1
            device: test100

    - name: Ensure that an IP inside 192.168.1.0/24 is attached to GigabitEthernet1
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          prefix: 192.168.1.0/24
          vrf: Test
          interface:
            name: GigabitEthernet1
            device: test100
        state: present

    - name: Attach a new available IP of 192.168.1.0/24 to GigabitEthernet1
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          prefix: 192.168.1.0/24
          vrf: Test
          interface:
            name: GigabitEthernet1
            device: test100
        state: new

    - name: Attach a new available IP of 192.168.1.0/24 to GigabitEthernet1 (NetBox 2.9+)
      netbox.netbox.netbox_ip_address:
        netbox_url: http://netbox.local
        netbox_token: thisIsMyToken
        data:
          prefix: 192.168.1.0/24
          vrf: Test
          assigned_object:
            name: GigabitEthernet1
            device: test100
        state: new
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
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m netbox.netbox.netbox_ip_address -a "<args>" -c local
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
- Target a single host directly: `ansible <hostname>, -m netbox.netbox.netbox_ip_address -a "..."` (note the trailing comma)
