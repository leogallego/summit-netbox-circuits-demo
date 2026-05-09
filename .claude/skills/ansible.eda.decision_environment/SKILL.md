---
name: ansible.eda.decision_environment
description: >-
  Create, update or delete decision environment in EDA Controller
  Use when managing decision environment resources via API with Ansible.
---

# ansible.eda.decision_environment

Create, update or delete decision environment in EDA Controller

## When to Use This Skill

Use the `ansible.eda.decision_environment` Ansible module when you need to manage decision environment resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `controller_host` | str | yes | - | The URL of the EDA controller. If not set, the value of C(CONTROLLER_HOST), or E(AAP_HOSTNAME) environment variables will be used. Support for E(AAP_HOSTNAME) has been added in version 2.7. |
| `name` | str | yes | - | The name of the decision environment. |
| `controller_password` | str | no | - | Password used for authentication. If not set, the value of C(CONTROLLER_PASSWORD), or E(AAP_PASSWORD) environment variables will be used. Support for E(AAP_PASSWORD) has been added in version 2.7. |
| `controller_token` | str | no | - | Token used for authentication. If not set, the value of C(CONTROLLER_TOKEN), E(AAP_TOKEN), or E(AAP_OAUTH_TOKEN) environment variables will be used. Support for E(CONTROLLER_TOKEN), E(AAP_TOKEN), and E(AAP_OAUTH_TOKEN) has been added in version 2.10. |
| `controller_username` | str | no | - | Username used for authentication. If not set, the value of C(CONTROLLER_USERNAME), or E(AAP_USERNAME) environment variables will be used. Support for E(AAP_USERNAME) has been added in version 2.7. |
| `credential` | str | no | - | Name of the credential to associate with the decision environment. |
| `description` | str | no | - | The description of the decision environment. |
| `image_url` | str | no | - | Image URL of the decision environment. |
| `new_name` | str | no | - | Setting this option will change the existing name. |
| `organization_name` | str | no | - | The name of the organization. AAP 2.4 does not support organization name. |
| `pull_policy` | str | no | always | Image pull policy for the decision environment container. C(always) pulls the image before starting the container. C(never) prevents pulling and uses local image. C(missing) only pulls if image is not available locally. For Kubernetes deployments, these values are converted to C(Always), C(Never), and C(IfNotPresent). |
| `request_timeout` | float | no | 10 | Timeout in seconds for the connection with the EDA controller. If not set, the value of C(CONTROLLER_TIMEOUT), E(AAP_REQUEST_TIMEOUT) environment variables will be used. Support for E(AAP_REQUEST_TIMEOUT) has been added in version 2.7. |
| `state` | str | no | present | Desired state of the resource. |
| `validate_certs` | bool | no | True | Whether to allow insecure connections to Ansible Automation Platform EDA Controller instance. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL), or E(AAP_VALIDATE_CERTS). Support for E(AAP_VALIDATE_CERTS) has been added in version 2.7. |
### Parameter Choices

- **pull_policy**: always, never, missing
- **state**: present, absent

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible localhost -m ansible.eda.decision_environment -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m ansible.eda.decision_environment -a "controller_host=<controller_host> name=Example Decision Environment" -c local --check --diff

# Apply the change
ansible localhost -m ansible.eda.decision_environment -a "controller_host=<controller_host> name=Example Decision Environment" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create EDA Decision Environment
  ansible.eda.decision_environment:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Decision Environment"
    description: "Example Decision Environment description"
    image_url: "quay.io/test"
    credential: "Example Credential"
    pull_policy: "missing"
    organization_name: Default
    state: present

- name: Update the name of the Decision Environment
  ansible.eda.decision_environment:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Decision Environment"
    new_name: "Latest Example Decision Environment"
    organization_name: Default
    state: present

- name: Delete the the Decision Environment
  ansible.eda.decision_environment:
    aap_hostname: https://my_eda_host/
    aap_username: admin
    aap_password: MySuperSecretPassw0rd
    name: "Example Decision Environment"
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
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m ansible.eda.decision_environment -a "<args>" -c local
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
- Target a single host directly: `ansible <hostname>, -m ansible.eda.decision_environment -a "..."` (note the trailing comma)
