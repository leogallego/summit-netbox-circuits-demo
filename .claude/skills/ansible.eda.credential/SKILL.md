---
name: ansible.eda.credential
description: >-
  Manage credentials in EDA Controller
  Use when managing credential resources on remote hosts via Ansible.
---

# ansible.eda.credential

Manage credentials in EDA Controller

## When to Use This Skill

Use the `ansible.eda.credential` Ansible module when you need to manage credential on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `controller_host` | str | yes | - | The URL of the EDA controller. If not set, the value of C(CONTROLLER_HOST), or E(AAP_HOSTNAME) environment variables will be used. Support for E(AAP_HOSTNAME) has been added in version 2.7. |
| `name` | str | yes | - | Name of the credential. |
| `controller_password` | str | no | - | Password used for authentication. If not set, the value of C(CONTROLLER_PASSWORD), or E(AAP_PASSWORD) environment variables will be used. Support for E(AAP_PASSWORD) has been added in version 2.7. |
| `controller_token` | str | no | - | Token used for authentication. If not set, the value of C(CONTROLLER_TOKEN), E(AAP_TOKEN), or E(AAP_OAUTH_TOKEN) environment variables will be used. Support for E(CONTROLLER_TOKEN), E(AAP_TOKEN), and E(AAP_OAUTH_TOKEN) has been added in version 2.10. |
| `controller_username` | str | no | - | Username used for authentication. If not set, the value of C(CONTROLLER_USERNAME), or E(AAP_USERNAME) environment variables will be used. Support for E(AAP_USERNAME) has been added in version 2.7. |
| `copy_from` | str | no | - | Name of the existing credential to copy. If set, copies the specified credential. The new credential will be created with the name given in the C(name) parameter. |
| `credential_type_name` | str | no | - | The name of the credential type. |
| `description` | str | no | - | Description of the credential. |
| `inputs` | dict | no | - | Credential inputs where the keys are var names used in templating. |
| `metadata` | dict | no | - | Additional configuration for testing specific secrets or configurations Only used when state is 'test' The structure depends on the credential type and external system For HashiCorp Vault, should include keys like 'secret_path' and 'secret_key' |
| `new_name` | str | no | - | Setting this option will change the existing name (lookup via name). |
| `organization_name` | str | no | - | The name of the organization. |
| `request_timeout` | float | no | 10 | Timeout in seconds for the connection with the EDA controller. If not set, the value of C(CONTROLLER_TIMEOUT), E(AAP_REQUEST_TIMEOUT) environment variables will be used. Support for E(AAP_REQUEST_TIMEOUT) has been added in version 2.7. |
| `state` | str | no | present | Desired state of the resource. C(present) - Create or update the credential C(absent) - Remove the credential C(test) - Test the credential connectivity without making any changes |
| `validate_certs` | bool | no | True | Whether to allow insecure connections to Ansible Automation Platform EDA Controller instance. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL), or E(AAP_VALIDATE_CERTS). Support for E(AAP_VALIDATE_CERTS) has been added in version 2.7. |
### Parameter Choices

- **state**: present, absent, test

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.eda.credential -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.eda.credential -a "controller_host=<controller_host> name=Example Credential" -b --check --diff

# Apply the change
ansible webservers -m ansible.eda.credential -a "controller_host=<controller_host> name=Example Credential" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create an EDA Credential
  ansible.eda.credential:
    name: "Example Credential"
    description: "Example credential description"
    inputs:
      field1: "field1"
    credential_type_name: "GitLab Personal Access Token"
    organization_name: Default

- name: Delete an EDA Credential
  ansible.eda.credential:
    name: "Example Credential"
    state: absent

- name: Copy an existing EDA Credential
  ansible.eda.credential:
    name: "New Copied Credential"
    copy_from: "Existing Credential"

- name: Test a HashiCorp Vault credential connectivity
  ansible.eda.credential:
    name: "vault_lookup_credential"
    state: test
    metadata:
      secret_path: "secret/myapp"
      secret_key: "password"
    organization_name: Default

- name: Test credential basic connectivity
  ansible.eda.credential:
    name: "my_aws_credential"
    state: test
    organization_name: Default
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.eda.credential -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.eda.credential -a "..."` (note the trailing comma)
