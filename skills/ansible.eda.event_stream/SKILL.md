---
name: ansible.eda.event_stream
description: >-
  Manage event streams in EDA Controller
  Use when managing event stream resources on remote hosts via Ansible.
---

# ansible.eda.event_stream

Manage event streams in EDA Controller

## When to Use This Skill

Use the `ansible.eda.event_stream` Ansible module when you need to manage event stream on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `controller_host` | str | yes | - | The URL of the EDA controller. If not set, the value of C(CONTROLLER_HOST), or E(AAP_HOSTNAME) environment variables will be used. Support for E(AAP_HOSTNAME) has been added in version 2.7. |
| `name` | str | yes | - | Name of the event stream. |
| `controller_password` | str | no | - | Password used for authentication. If not set, the value of C(CONTROLLER_PASSWORD), or E(AAP_PASSWORD) environment variables will be used. Support for E(AAP_PASSWORD) has been added in version 2.7. |
| `controller_token` | str | no | - | Token used for authentication. If not set, the value of C(CONTROLLER_TOKEN), E(AAP_TOKEN), or E(AAP_OAUTH_TOKEN) environment variables will be used. Support for E(CONTROLLER_TOKEN), E(AAP_TOKEN), and E(AAP_OAUTH_TOKEN) has been added in version 2.10. |
| `controller_username` | str | no | - | Username used for authentication. If not set, the value of C(CONTROLLER_USERNAME), or E(AAP_USERNAME) environment variables will be used. Support for E(AAP_USERNAME) has been added in version 2.7. |
| `credential_name` | str | no | - | The name of the credential. The type of credential can only be one of ['HMAC Event Stream', 'Basic Event Stream', 'Token Event Stream', 'OAuth2 Event Stream', 'OAuth2 JWT Event Stream', 'ECDSA Event Stream', 'mTLS Event Stream', 'GitLab Event Stream', 'GitHub Event Stream', 'ServiceNow Event Stream', 'Dynatrace Event Stream'] |
| `event_stream_type` | str | no | - | Type of the event stream. This field is not necessary to create an event stream and will be ignored. This field will be removed in version 3.0.0. |
| `forward_events` | bool | no | False | Enable the event stream to forward events to the rulebook activation where it is configured. |
| `headers` | str | no |  | Comma separated HTTP header keys that you want to include in the event payload. To include all headers in the event payload, leave the field empty. |
| `new_name` | str | no | - | Setting this option will change the existing name (lookup via name). |
| `organization_name` | str | no | - | The name of the organization. |
| `request_timeout` | float | no | 10 | Timeout in seconds for the connection with the EDA controller. If not set, the value of C(CONTROLLER_TIMEOUT), E(AAP_REQUEST_TIMEOUT) environment variables will be used. Support for E(AAP_REQUEST_TIMEOUT) has been added in version 2.7. |
| `state` | str | no | present | Desired state of the resource. |
| `uuid` | str | no | - | Custom UUID for the event stream URL. If not provided, UUID will be auto-generated. Must be unique across all event streams. |
| `validate_certs` | bool | no | True | Whether to allow insecure connections to Ansible Automation Platform EDA Controller instance. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL), or E(AAP_VALIDATE_CERTS). Support for E(AAP_VALIDATE_CERTS) has been added in version 2.7. |
### Parameter Choices

- **state**: present, absent

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.eda.event_stream -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.eda.event_stream -a "controller_host=<controller_host> name=Example Event Stream" -b --check --diff

# Apply the change
ansible webservers -m ansible.eda.event_stream -a "controller_host=<controller_host> name=Example Event Stream" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create an EDA Event Stream
  ansible.eda.event_stream:
    name: "Example Event Stream"
    credential_name: "Example Credential"
    organization_name: Default

- name: Create an EDA Event Stream with custom UUID
  ansible.eda.event_stream:
    name: "Static Event Stream"
    uuid: "550e8400-e29b-41d4-a716-446655440000"
    credential_name: "Example Credential"
    organization_name: Default

- name: Delete an EDA Event Stream
  ansible.eda.event_stream:
    name: "Example Event Stream"
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.eda.event_stream -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.eda.event_stream -a "..."` (note the trailing comma)
