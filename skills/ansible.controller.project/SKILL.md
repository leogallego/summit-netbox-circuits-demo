---
name: ansible.controller.project
description: >-
  create, update, or destroy Automation Platform Controller projects
  Use when managing project resources via API with Ansible.
---

# ansible.controller.project

create, update, or destroy Automation Platform Controller projects

## When to Use This Skill

Use the `ansible.controller.project` Ansible module when you need to manage project resources via API. This module runs on the **control host** (not over SSH) and communicates with an external API.

- Runs with `connection: local` -- no SSH to remote hosts
- **Does not** require `become`/sudo
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | str | yes | - | Name to use for the project. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `allow_override` | bool | no | - | Allow changing the SCM branch or revision in a job template that uses this project. |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `copy_from` | str | no | - | Name or id to copy the project from. This will copy an existing project and change any parameters supplied. The new project name will be the one provided in the name parameter. The organization parameter is not used in this, to facilitate copy from one organization to another. Provide the id or use the lookup plugin to provide the id if multiple projects share the same name. |
| `credential` | str | no | - | Name, ID, or named URL of the credential to use with this SCM resource. |
| `custom_virtualenv` | str | no | - | Local absolute file path containing a custom Python virtualenv to use. Only compatible with older versions of AWX/Tower Deprecated, will be removed in the future |
| `default_environment` | str | no | - | Default Execution Environment name, ID, or named URL to use for jobs relating to the project. |
| `description` | str | no | - | Description to use for the project. |
| `interval` | float | no | 2 | The interval to request an update from the controller. Requires wait. |
| `local_path` | str | no | - | The server playbook directory for manual projects. |
| `new_name` | str | no | - | Setting this option will change the existing name (looked up via the name field. |
| `notification_templates_error` | list | no | - | list of notifications to send on error |
| `notification_templates_started` | list | no | - | list of notifications to send on start |
| `notification_templates_success` | list | no | - | list of notifications to send on success |
| `organization` | str | no | - | Name, ID, or named URL of organization for the project. |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `scm_branch` | str | no | - | The branch to use for the SCM resource. |
| `scm_clean` | bool | no | - | Remove local modifications before updating. |
| `scm_delete_on_update` | bool | no | - | Remove the repository completely before updating. |
| `scm_refspec` | str | no | - | The refspec to use for the SCM resource. |
| `scm_track_submodules` | bool | no | - | Track submodules latest commit on specified branch. |
| `scm_type` | str | no | - | Type of SCM resource. |
| `scm_update_cache_timeout` | int | no | - | Cache Timeout to cache prior project syncs for a certain number of seconds. Only valid if scm_update_on_launch is to True, otherwise ignored. |
| `scm_update_on_launch` | bool | no | - | Perform an update to the local repository before launching a job with this project. |
| `scm_url` | str | no | - | URL of SCM resource. |
| `signature_validation_credential` | str | no | - | Name, ID, or named URL of the credential to use for signature validation. If signature validation credential is provided, signature validation will be enabled. |
| `state` | str | no | present | Desired state of the resource. |
| `timeout` | int | no | - | The amount of time (in seconds) to run before the SCM Update is canceled. A value of 0 means no timeout. If waiting for the project to update this will abort after this amount of seconds |
| `update_project` | bool | no | False | Force project to update after changes. Used in conjunction with wait, interval, and timeout. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
| `wait` | bool | no | True | Provides option (True by default) to wait for completed project sync before returning Can assure playbook files are populated so that job templates that rely on the project may be successfully created |
### Parameter Choices

- **scm_type**: manual, git, svn, insights, archive
- **state**: present, absent, exists

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible localhost -m ansible.controller.project -a "<key=value arguments>" -c local --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible localhost -m ansible.controller.project -a "name=Foo" -c local --check --diff

# Apply the change
ansible localhost -m ansible.controller.project -a "name=Foo" -c local --diff
```

### Examples from Ansible Documentation

```yaml
- name: Add project
  project:
    name: "Foo"
    description: "Foo bar project"
    organization: "test"
    state: present
    controller_config_file: "~/tower_cli.cfg"

- name: Add Project with cache timeout
  project:
    name: "Foo"
    description: "Foo bar project"
    organization: "test"
    scm_update_on_launch: true
    scm_update_cache_timeout: 60
    state: present
    controller_config_file: "~/tower_cli.cfg"

- name: Copy project
  project:
    name: copy
    copy_from: test
    description: Foo copy project
    organization: Foo
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
ANSIBLE_STDOUT_CALLBACK=json ansible localhost -m ansible.controller.project -a "<args>" -c local
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.project -a "..."` (note the trailing comma)
