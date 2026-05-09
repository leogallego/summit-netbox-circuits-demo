---
name: ansible.eda.rulebook_activation
description: >-
  Manage rulebook activations in the EDA Controller
  Use when managing rulebook activation resources on remote hosts via Ansible.
---

# ansible.eda.rulebook_activation

Manage rulebook activations in the EDA Controller

## When to Use This Skill

Use the `ansible.eda.rulebook_activation` Ansible module when you need to manage rulebook activation on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `controller_host` | str | yes | - | The URL of the EDA controller. If not set, the value of C(CONTROLLER_HOST), or E(AAP_HOSTNAME) environment variables will be used. Support for E(AAP_HOSTNAME) has been added in version 2.7. |
| `name` | str | yes | - | The name of the rulebook activation. |
| `awx_token_name` | str | no | - | The token ID of the AWX controller. |
| `controller_password` | str | no | - | Password used for authentication. If not set, the value of C(CONTROLLER_PASSWORD), or E(AAP_PASSWORD) environment variables will be used. Support for E(AAP_PASSWORD) has been added in version 2.7. |
| `controller_token` | str | no | - | Token used for authentication. If not set, the value of C(CONTROLLER_TOKEN), E(AAP_TOKEN), or E(AAP_OAUTH_TOKEN) environment variables will be used. Support for E(CONTROLLER_TOKEN), E(AAP_TOKEN), and E(AAP_OAUTH_TOKEN) has been added in version 2.10. |
| `controller_username` | str | no | - | Username used for authentication. If not set, the value of C(CONTROLLER_USERNAME), or E(AAP_USERNAME) environment variables will be used. Support for E(AAP_USERNAME) has been added in version 2.7. |
| `decision_environment_name` | str | no | - | The name of the decision environment associated with the rulebook activation. Required when state is present. |
| `description` | str | no | - | The description of the rulebook activation. |
| `eda_credentials` | list | no | - | A list of IDs for EDA credentials used by the rulebook activation. This parameter is supported in AAP 2.5 and onwards. If specified for AAP 2.4, value will be ignored. |
| `enabled` | bool | no | True | Whether the rulebook activation is enabled or not. This field will be removed in version 3.0.0. The logic of controlling the state of an activation is going to be controlled by the C(state) parameter itself. |
| `event_streams` | list | no | - | A list of event stream names that this rulebook activation listens to. This parameter is supported in AAP 2.5 and onwards. If specified for AAP 2.4, value will be ignored. |
| `extra_vars` | str | no | - | The extra variables for the rulebook activation. |
| `k8s_service_name` | str | no | - | The name of the Kubernetes service associated with this rulebook activation. This parameter is supported in AAP 2.5 and onwards. If specified for AAP 2.4, value will be ignored. |
| `log_level` | str | no | error | Allow setting the desired log level. This parameter is supported in AAP 2.5 and onwards. If specified for AAP 2.4, value will be ignored. |
| `new_name` | str | no | - | Renames an existing rulebook activation. If set, the rulebook activation will be updated with the new name. |
| `organization_name` | str | no | - | The name of the organization. Required when state is present. This parameter is supported in AAP 2.5 and onwards. If specified for AAP 2.4, value will be ignored. |
| `project_name` | str | no | - | The name of the project associated with the rulebook activation. Required when state is present. |
| `request_timeout` | float | no | 10 | Timeout in seconds for the connection with the EDA controller. If not set, the value of C(CONTROLLER_TIMEOUT), E(AAP_REQUEST_TIMEOUT) environment variables will be used. Support for E(AAP_REQUEST_TIMEOUT) has been added in version 2.7. |
| `restart` | bool | no | False | Performs a restart of the activation. This is a non idempotent operation. If enabled the rest of parameters will be ignored. |
| `restart_policy` | str | no | on-failure | The restart policy for the rulebook activation. |
| `rulebook_name` | str | no | - | The name of the rulebook associated with the rulebook activation. Required when state is present. |
| `state` | str | no | present | Desired state of the resource. The state of an activation itself is controlled by this parameter, whether I(enabled) or I(disabled). When an activation is created, it is I(enabled) by default. Thus, I(present) is equivalent to I(enabled). Whether I(present), I(enabled), or I(disabled) is specified, an activation will be created if it doesn't exist already. To create a disabled activation, specify C(state) as I(disabled). Essentially, this parameter deprecates the usage of C(enabled). |
| `swap_single_source` | bool | no | True | Allow swapping of single sources in a rulebook without name match. This parameter is no longer used and is going to be ignored. This field will be removed in version 3.0.0. |
| `validate_certs` | bool | no | True | Whether to allow insecure connections to Ansible Automation Platform EDA Controller instance. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL), or E(AAP_VALIDATE_CERTS). Support for E(AAP_VALIDATE_CERTS) has been added in version 2.7. |
### Parameter Choices

- **log_level**: debug, info, error
- **restart_policy**: on-failure, always, never
- **state**: present, absent, disabled, enabled

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.eda.rulebook_activation -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.eda.rulebook_activation -a "controller_host=<controller_host> name=Example Rulebook Activation" -b --check --diff

# Apply the change
ansible webservers -m ansible.eda.rulebook_activation -a "controller_host=<controller_host> name=Example Rulebook Activation" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    description: "Example Rulebook Activation description"
    project_name: "Example Project"
    rulebook_name: "hello_controller.yml"
    decision_environment_name: "Example Decision Environment"
    state: disabled

- name: Create a rulebook activation with event_streams option
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    description: "Example Activation description"
    project_name: "Example Project"
    rulebook_name: "hello_controller.yml"
    decision_environment_name: "Example Decision Environment"
    state: disabled
    organization_name: "Default"
    event_streams:
      - event_stream: "Example Event Stream"
        source_name: "Sample source"

- name: Rename a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    new_name: "Example Rulebook Activation New Name"
    project_name: "Example Project"
    rulebook_name: "hello_controller.yml"
    decision_environment_name: "Example Decision Environment"
    organization_name: "Default"

- name: Update a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    log_level: debug
    restart_policy: always
    project_name: "Example Project"
    rulebook_name: "hello_controller.yml"
    decision_environment_name: "Example Decision Environment"
    organization_name: "Default"

- name: Enable a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    state: enabled

- name: Disable a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
    new_name: "Example Rulebook Activation New Name"
    state: disabled

- name: Restart activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation - Restart"
    organization_name: "Default"
    restart: true

- name: Delete a rulebook activation
  ansible.eda.rulebook_activation:
    name: "Example Rulebook Activation"
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.eda.rulebook_activation -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.eda.rulebook_activation -a "..."` (note the trailing comma)
