---
name: ansible.eda.project
description: >-
  Create, update or delete project in EDA Controller
  Use when managing project resources via API with Ansible.
---

# ansible.eda.project

Create, update or delete project in EDA Controller

## When to Use This Skill

Use the `ansible.eda.project` Ansible module when you need to manage project resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `controller_host` | str | yes | - | The URL of the EDA controller. If not set, the value of C(CONTROLLER_HOST), or E(AAP_HOSTNAME) environment variables will be used. Support for E(AAP_HOSTNAME) has been added in version 2.7. |
| `name` | str | yes | - | The name of the project. |
| `controller_password` | str | no | - | Password used for authentication. If not set, the value of C(CONTROLLER_PASSWORD), or E(AAP_PASSWORD) environment variables will be used. Support for E(AAP_PASSWORD) has been added in version 2.7. |
| `controller_token` | str | no | - | Token used for authentication. If not set, the value of C(CONTROLLER_TOKEN), E(AAP_TOKEN), or E(AAP_OAUTH_TOKEN) environment variables will be used. Support for E(CONTROLLER_TOKEN), E(AAP_TOKEN), and E(AAP_OAUTH_TOKEN) has been added in version 2.10. |
| `controller_username` | str | no | - | Username used for authentication. If not set, the value of C(CONTROLLER_USERNAME), or E(AAP_USERNAME) environment variables will be used. Support for E(AAP_USERNAME) has been added in version 2.7. |
| `credential` | str | no | - | The name of the credential to associate with the project. |
| `description` | str | no | - | The description of the project. |
| `new_name` | str | no | - | Setting this option will change the existing name. |
| `organization_name` | str | no | - | The name of the organization. AAP 2.4 does not support organization name. |
| `proxy` | str | no | - | Proxy used to access HTTP or HTTPS servers. |
| `request_timeout` | float | no | 10 | Timeout in seconds for the connection with the EDA controller. If not set, the value of C(CONTROLLER_TIMEOUT), E(AAP_REQUEST_TIMEOUT) environment variables will be used. Support for E(AAP_REQUEST_TIMEOUT) has been added in version 2.7. |
| `scm_branch` | str | no | - | The scm branch of the git project. |
| `state` | str | no | present | Desired state of the resource. |
| `sync` | bool | no | False | Triggers the synchronization of the project. This only takes effect when the project already exists. |
| `url` | str | no | - | The git URL of the project. |
| `validate_certs` | bool | no | True | Whether to allow insecure connections to Ansible Automation Platform EDA Controller instance. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL), or E(AAP_VALIDATE_CERTS). Support for E(AAP_VALIDATE_CERTS) has been added in version 2.7. |
### Parameter Choices

- **state**: present, absent

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible localhost -m ansible.eda.project -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m ansible.eda.project -a "controller_host=<controller_host> name=Example Project" -c local --check --diff

# Apply the change
ansible localhost -m ansible.eda.project -a "controller_host=<controller_host> name=Example Project" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create EDA Projects
  ansible.eda.project:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Project"
    description: "Example project description"
    url: "https://example.com/project1"
    proxy: "https://example.com"
    organization_name: Default
    state: present

- name: Update the name of the project
  ansible.eda.project:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Project"
    new_name: "Latest Example Project"
    description: "Example project description"
    url: "https://example.com/project1"
    scm_branch: "devel"
    organization_name: Default
    state: present

- name: Delete the project
  ansible.eda.project:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Project"
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
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m ansible.eda.project -a "<args>" -c local
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
- Target a single host directly: `ansible <hostname>, -m ansible.eda.project -a "..."` (note the trailing comma)
