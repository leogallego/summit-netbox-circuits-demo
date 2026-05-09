---
name: ansible.controller.workflow_job_template
description: >-
  create, update, or destroy Automation Platform Controller workflow job templates.
  Use when managing workflow job template resources on remote hosts via Ansible.
---

# ansible.controller.workflow_job_template

create, update, or destroy Automation Platform Controller workflow job templates.

## When to Use This Skill

Use the `ansible.controller.workflow_job_template` Ansible module when you need to manage workflow job template on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `name` | str | yes | - | Name of this workflow job template. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `allow_simultaneous` | bool | no | - | Allow simultaneous runs of the workflow job template. |
| `ask_inventory_on_launch` | bool | no | - | Prompt user for inventory on launch of this workflow job template |
| `ask_labels_on_launch` | bool | no | - | Prompt user for labels on launch. |
| `ask_limit_on_launch` | bool | no | - | Prompt user for limit on launch of this workflow job template |
| `ask_scm_branch_on_launch` | bool | no | - | Prompt user for SCM branch on launch of this workflow job template |
| `ask_skip_tags_on_launch` | bool | no | - | Prompt user for job tags to skip on launch. |
| `ask_tags_on_launch` | bool | no | - | Prompt user for job tags on launch. |
| `ask_variables_on_launch` | bool | no | - | Prompt user for C(extra_vars) on launch. |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `copy_from` | str | no | - | Name or id to copy the workflow job template from. This will copy an existing workflow job template and change any parameters supplied. The new workflow job template name will be the one provided in the name parameter. The organization parameter is not used in this, to facilitate copy from one organization to another. Provide the id or use the lookup plugin to provide the id if multiple workflow job templates share the same name. |
| `description` | str | no | - | Optional description of this workflow job template. |
| `destroy_current_nodes` | bool | no | False | Set in order to destroy current workflow_nodes on the workflow. This option is used for full workflow update, if not used, nodes not described in workflow will persist and keep current associations and links. |
| `extra_vars` | dict | no | - | Variables which will be made available to jobs ran inside the workflow. |
| `inventory` | str | no | - | Name, ID, or named URL of inventory applied as a prompt, assuming job template prompts for inventory |
| `job_tags` | str | no | - | Comma separated list of the tags to use for the job template. |
| `labels` | list | no | - | The labels applied to this job template Must be created with the labels module first. This will error if the label has not been created. |
| `limit` | str | no | - | Limit applied as a prompt, assuming job template prompts for limit |
| `new_name` | str | no | - | Setting this option will change the existing name. |
| `notification_templates_approvals` | list | no | - | list of notifications to send on approval |
| `notification_templates_error` | list | no | - | list of notifications to send on error |
| `notification_templates_started` | list | no | - | list of notifications to send on start |
| `notification_templates_success` | list | no | - | list of notifications to send on success |
| `organization` | str | no | - | Organization name, ID, or named URL the workflow job template exists in. Used to help lookup the object, cannot be modified using this module. If not provided, will lookup by name only, which does not work with duplicates. |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `scm_branch` | str | no | - | SCM branch applied as a prompt, assuming job template prompts for SCM branch |
| `skip_tags` | str | no | - | Comma separated list of the tags to skip for the job template. |
| `state` | str | no | present | Desired state of the resource. |
| `survey_enabled` | bool | no | - | Setting that variable will prompt the user for job type on the workflow launch. |
| `survey_spec` | dict | no | - | The definition of the survey associated to the workflow. |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
| `webhook_credential` | str | no | - | Personal Access Token for posting back the status to the service API |
| `webhook_service` | str | no | - | Service that webhook requests will be accepted from |
| `workflow_nodes` | list | no | - | A json list of nodes and their coresponding options. The following suboptions describe a single node. |
### Parameter Choices

- **state**: present, absent, exists
- **webhook_service**: github, gitlab

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.workflow_job_template -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.workflow_job_template -a "name=example-workflow" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.workflow_job_template -a "name=example-workflow" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Create a workflow job template
  workflow_job_template:
    name: example-workflow
    description: created by Ansible Playbook
    organization: Default

- name: Create a workflow job template with workflow nodes in template
  awx.awx.workflow_job_template:
    name: example-workflow
    inventory: Demo Inventory
    extra_vars: {'foo': 'bar', 'another-foo': {'barz': 'bar2'}}
    workflow_nodes:
      - identifier: node101
        unified_job_template:
          name: example-project
          inventory:
            organization:
              name: Default
          type: inventory_source
        related:
          success_nodes: []
          failure_nodes:
            - identifier: node201
          always_nodes: []
          credentials:
            - local_cred
            - suplementary cred
      - identifier: node201
        unified_job_template:
          organization:
            name: Default
          name: job template 1
          type: job_template
        credentials: []
        related:
          success_nodes:
            - identifier: node301
          failure_nodes: []
          always_nodes: []
          credentials: []
      - identifier: node202
        unified_job_template:
          organization:
            name: Default
          name: example-project
          type: project
        related:
          success_nodes: []
          failure_nodes: []
          always_nodes: []
          credentials: []
      - identifier: node301
        all_parents_must_converge: false
        unified_job_template:
          organization:
            name: Default
          name: job template 2
          type: job_template
        related:
          success_nodes: []
          failure_nodes: []
          always_nodes: []
          credentials: []
  register: result

- name: Copy a workflow job template
  workflow_job_template:
    name: copy-workflow
    copy_from: example-workflow
    organization: Foo

- name: Create a workflow job template with workflow nodes in template
  awx.awx.workflow_job_template:
    name: example-workflow
    inventory: Demo Inventory
    extra_vars: {'foo': 'bar', 'another-foo': {'barz': 'bar2'}}
    workflow_nodes:
      - identifier: node101
        unified_job_template:
          name: example-inventory
          inventory:
            organization:
              name: Default
          type: inventory_source
        related:
          failure_nodes:
            - identifier: node201
      - identifier: node102
        unified_job_template:
          organization:
            name: Default
          name: example-project
          type: project
        related:
          success_nodes:
            - identifier: node201
      - identifier: node201
        unified_job_template:
          organization:
            name: Default
          name: example-job template
          type: job_template
        inventory:
          name: Demo Inventory
          organization:
            name: Default
        related:
          success_nodes:
            - identifier: node401
          failure_nodes:
            - identifier: node301
          always_nodes: []
          credentials:
            - name: cyberark
              organization:
                name: Default
          instance_groups:
            - name: SunCavanaugh Cloud
          labels:
            - name: Custom Label
              organization:
                name: Default
      - all_parents_must_converge: false
        identifier: node301
        unified_job_template:
          description: Approval node for example
          timeout: 900
          type: workflow_approval
          name: Approval Node for Demo
        related:
          success_nodes:
            - identifier: node401
      - identifier: node401
        unified_job_template:
          name: Cleanup Activity Stream
          type: system_job_template
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.workflow_job_template -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.workflow_job_template -a "..."` (note the trailing comma)
