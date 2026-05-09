---
name: ansible.controller.job_template
description: >-
  create, update, or destroy job templates.
  Use when managing job template resources on remote hosts via Ansible.
---

# ansible.controller.job_template

create, update, or destroy job templates.

## When to Use This Skill

Use the `ansible.controller.job_template` Ansible module when you need to manage job template on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | str | yes | - | Name to use for the job template. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `allow_simultaneous` | bool | no | - | Allow simultaneous runs of the job template. |
| `ask_credential_on_launch` | bool | no | - | Prompt user for credential on launch. |
| `ask_diff_mode_on_launch` | bool | no | - | Prompt user to enable diff mode (show changes) to files when supported by modules. |
| `ask_execution_environment_on_launch` | bool | no | - | Prompt user for execution environment on launch. |
| `ask_forks_on_launch` | bool | no | - | Prompt user for forks on launch. |
| `ask_instance_groups_on_launch` | bool | no | - | Prompt user for instance groups on launch. |
| `ask_inventory_on_launch` | bool | no | - | Prompt user for inventory on launch. |
| `ask_job_slice_count_on_launch` | bool | no | - | Prompt user for job slice count on launch. |
| `ask_job_type_on_launch` | bool | no | - | Prompt user for job type on launch. |
| `ask_labels_on_launch` | bool | no | - | Prompt user for labels on launch. |
| `ask_limit_on_launch` | bool | no | - | Prompt user for a limit on launch. |
| `ask_scm_branch_on_launch` | bool | no | - | Prompt user for (scm branch) on launch. |
| `ask_skip_tags_on_launch` | bool | no | - | Prompt user for job tags to skip on launch. |
| `ask_tags_on_launch` | bool | no | - | Prompt user for job tags on launch. |
| `ask_timeout_on_launch` | bool | no | - | Prompt user for timeout on launch. |
| `ask_variables_on_launch` | bool | no | - | Prompt user for (extra_vars) on launch. |
| `ask_verbosity_on_launch` | bool | no | - | Prompt user to choose a verbosity level on launch. |
| `become_enabled` | bool | no | - | Activate privilege escalation. |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `copy_from` | str | no | - | Name or id to copy the job template from. This will copy an existing job template and change any parameters supplied. The new job template name will be the one provided in the name parameter. The organization parameter is not used in this, to facilitate copy from one organization to another. Provide the id or use the lookup plugin to provide the id if multiple job templates share the same name. |
| `credential` | str | no | - | Name, ID, or named URL of the credential to use for the job template. Deprecated, use 'credentials'. |
| `credentials` | list | no | - | List of credential names, IDs, or named URLs to use for the job template. |
| `custom_virtualenv` | str | no | - | Local absolute file path containing a custom Python virtualenv to use. Only compatible with older versions of AWX/Tower Deprecated, will be removed in the future |
| `description` | str | no | - | Description to use for the job template. |
| `diff_mode` | bool | no | - | Enable diff mode for the job template. |
| `execution_environment` | str | no | - | Execution Environment name, ID, or named URL to use for the job template. |
| `extra_vars` | dict | no | - | Specify C(extra_vars) for the template. |
| `force_handlers` | bool | no | - | Enable forcing playbook handlers to run even if a task fails. |
| `forks` | int | no | - | The number of parallel or simultaneous processes to use while executing the playbook. |
| `host_config_key` | str | no | - | Allow provisioning callbacks using this host config key. |
| `instance_groups` | list | no | - | list of Instance Group names, IDs, or named URLs for this Organization to run on. |
| `inventory` | str | no | - | Name, ID, or named URL of the inventory to use for the job template. |
| `job_slice_count` | int | no | - | The number of jobs to slice into at runtime. Will cause the Job Template to launch a workflow if value is greater than 1. |
| `job_tags` | str | no | - | Comma separated list of the tags to use for the job template. |
| `job_type` | str | no | - | The job type to use for the job template. |
| `labels` | list | no | - | The labels applied to this job template Must be created with the labels module first. This will error if the label has not been created. |
| `limit` | str | no | - | A host pattern to further constrain the list of hosts managed or affected by the playbook |
| `new_name` | str | no | - | Setting this option will change the existing name (looked up via the name field. |
| `notification_templates_error` | list | no | - | list of notifications to send on error |
| `notification_templates_started` | list | no | - | list of notifications to send on start |
| `notification_templates_success` | list | no | - | list of notifications to send on success |
| `organization` | str | no | - | Organization name, ID, or named URL the job template exists in. Used to help lookup the object, cannot be modified using this module. The Organization is inferred from the associated project If not provided, will lookup by name only, which does not work with duplicates. Requires Automation Platform Version 3.7.0 or AWX 10.0.0 IS NOT backwards compatible with earlier versions. |
| `playbook` | str | no | - | Path to the playbook to use for the job template within the project provided. |
| `prevent_instance_group_fallback` | bool | no | - | Prevent falling back to instance groups set on the associated inventory or organization |
| `project` | str | no | - | Name, ID, or named URL of the project to use for the job template. |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `scm_branch` | str | no | - | Branch to use in job run. Project default used if blank. Only allowed if project allow_override field is set to true. |
| `skip_tags` | str | no | - | Comma separated list of the tags to skip for the job template. |
| `start_at_task` | str | no | - | Start the playbook at the task matching this name. |
| `state` | str | no | present | Desired state of the resource. |
| `survey_enabled` | bool | no | - | Enable a survey on the job template. |
| `survey_spec` | dict | no | - | JSON/YAML dict formatted survey definition. |
| `timeout` | int | no | - | Maximum time in seconds to wait for a job to finish (server-side). |
| `use_fact_cache` | bool | no | - | Enable use of fact caching for the job template. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
| `vault_credential` | str | no | - | Name, ID, or named URL of the vault credential to use for the job template. Deprecated, use 'credentials'. |
| `verbosity` | int | no | - | Control the output level Ansible produces as the playbook runs. 0 - Normal, 1 - Verbose, 2 - More Verbose, 3 - Debug, 4 - Connection Debug. |
| `webhook_credential` | str | no | - | Personal Access Token for posting back the status to the service API |
| `webhook_service` | str | no | - | Service that webhook requests will be accepted from |
### Parameter Choices

- **job_type**: run, check
- **state**: present, absent, exists
- **verbosity**: 0, 1, 2, 3, 4, 5
- **webhook_service**: , github, gitlab

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.job_template -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.job_template -a "name=Ping" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.job_template -a "name=Ping" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create Ping job template
  job_template:
    name: "Ping"
    job_type: "run"
    organization: "Default"
    inventory: "Local"
    project: "Demo"
    playbook: "ping.yml"
    credentials:
      - "Local"
      - "2nd credential"
    state: "present"
    controller_config_file: "~/tower_cli.cfg"
    survey_enabled: true
    survey_spec: "{{ lookup('file', 'my_survey.json') }}"

- name: Add start notification to Job Template
  job_template:
    name: "Ping"
    notification_templates_started:
      - Notification1
      - Notification2

- name: Remove Notification1 start notification from Job Template
  job_template:
    name: "Ping"
    notification_templates_started:
      - Notification2

- name: Copy Job Template
  job_template:
    name: copy job template
    copy_from: test job template
    job_type: "run"
    inventory: Copy Foo Inventory
    project: test
    playbook: hello_world.yml
    state: "present"
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.job_template -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.job_template -a "..."` (note the trailing comma)
