---
name: ansible.controller.credential
description: >-
  create, update, or destroy Automation Platform Controller credential.
  Use when managing credential resources on remote hosts via Ansible.
---

# ansible.controller.credential

create, update, or destroy Automation Platform Controller credential.

## When to Use This Skill

Use the `ansible.controller.credential` Ansible module when you need to manage credential on remote hosts. This is preferable to local CLI commands when:

- Targeting one or more **remote** hosts over SSH
- You need **idempotent** state management (ensure a desired state, not just run a command)
- You want **audit trails** and **dry-run** capability via `--check`

Do **not** use this for basic local file operations or CLI tasks that the agent can handle natively.

## Parameters

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `credential_type` | str | yes | - | The credential type being created. Can be a built-in credential type such as "Machine", or a custom credential type such as "My Credential Type" Choices include Amazon Web Services, Ansible Galaxy/Automation Hub API Token, Centrify Vault Credential Provider Lookup, Container Registry, CyberArk Central Credential Provider Lookup, CyberArk Conjur Secret Lookup, Google Compute Engine, GitHub Personal Access Token, GitLab Personal Access Token, GPG Public Key, HashiCorp Vault Secret Lookup, HashiCorp Vault Signed SSH, Insights, Machine, Microsoft Azure Key Vault, Microsoft Azure Resource Manager, Network, OpenShift or Kubernetes API Bearer Token, OpenStack, Red Hat Ansible Automation Platform, Red Hat Satellite 6, Red Hat Virtualization, Source Control, Thycotic DevOps Secrets Vault, Thycotic Secret Server, Vault, VMware vCenter, or a custom credential type |
| `name` | str | yes | - | The name to use for the credential. |
| `aap_token` | raw | no | - | The OAuth token to use. This value can be in one of two formats. A string which is the token itself. (i.e. bqV5txm97wqJqtkxlMkhQz0pKhRMMX) A dictionary structure as returned by the token module. If value not set, will try environment variable C(CONTROLLER_OAUTH_TOKEN) and then config files |
| `controller_config_file` | path | no | - | Path to the controller config file. If provided, the other locations for config files will not be considered. |
| `controller_host` | str | no | - | URL to your Automation Platform Controller instance. If value not set, will try environment variable C(CONTROLLER_HOST) and then config files If value not specified by any means, the value of C(127.0.0.1) will be used |
| `controller_password` | str | no | - | Password for your controller instance. If value not set, will try environment variable C(CONTROLLER_PASSWORD) and then config files |
| `controller_username` | str | no | - | Username for your controller instance. If value not set, will try environment variable C(CONTROLLER_USERNAME) and then config files |
| `copy_from` | str | no | - | Name or id to copy the credential from. This will copy an existing credential and change any parameters supplied. The new credential name will be the one provided in the name parameter. The organization parameter is not used in this, to facilitate copy from one organization to another. Provide the id or use the lookup plugin to provide the id if multiple credentials share the same name. |
| `description` | str | no | - | The description to use for the credential. |
| `inputs` | dict | no | - | Credential inputs where the keys are var names used in templating. Refer to the Automation Platform Controller documentation for example syntax. authorize (use this for net type) authorize_password (password for net credentials that require authorize) client (client or application ID for azure_rm type) security_token (STS token for aws type) secret (secret token for azure_rm type) tenant (tenant ID for azure_rm type) subscription (subscription ID for azure_rm type) domain (domain for openstack type) become_method (become method to use for privilege escalation; some examples are "None", "sudo", "su", "pbrun") become_username (become username; use "ASK" and launch job to be prompted) become_password (become password; use "ASK" and launch job to be prompted) vault_password (the vault password; use "ASK" and launch job to be prompted) project (project that should use this credential for GCP) host (the host for this credential) username (the username for this credential; ``access_key`` for AWS) password (the password for this credential; ``secret_key`` for AWS, ``api_key`` for RAX) ssh_key_data (SSH private key content; to extract the content from a file path, use the lookup function (see examples)) vault_id (the vault identifier; this parameter is only valid if C(kind) is specified as C(vault).) ssh_key_unlock (unlock password for ssh_key; use "ASK" and launch job to be prompted) gpg_public_key (GPG Public Key used for signature validation) client_id (client ID insights type service account) client_secret (client secret insights type service account) |
| `new_name` | str | no | - | Setting this option will change the existing name (looked up via the name field. |
| `organization` | str | no | - | Organization name, ID, or named URL that should own the credential. This parameter is mutually exclusive with C(team) and C(user). |
| `request_timeout` | float | no | - | Specify the timeout Ansible should use in requests to the controller host. Defaults to 10s, but this is handled by the shared module_utils code |
| `state` | str | no | present | Desired state of the resource. C(exists) will not modify the resource if it is present. |
| `team` | str | no | - | Team name, ID, or named URL that should own this credential. This parameter is mutually exclusive with C(organization) and C(user). |
| `update_secrets` | bool | no | True | C(true) will always update encrypted values. C(false) will only update encrypted values if a change is absolutely known to be needed. |
| `user` | str | no | - | User name, ID, or named URL that should own this credential. This parameter is mutually exclusive with C(organization) and C(team). |
| `validate_certs` | bool | no | - | Whether to allow insecure connections to AWX. If C(no), SSL certificates will not be validated. This should only be used on personally controlled sites using self-signed certificates. If value not set, will try environment variable C(CONTROLLER_VERIFY_SSL) and then config files |
### Parameter Choices

- **state**: present, absent, exists

## Usage

Run this module using the `ansible` CLI (from `ansible-core`):

```bash
ansible <host-pattern> -m ansible.controller.credential -a "<key=value arguments>" -b --check --diff
```

### Quick Examples

```bash
# Dry-run first (always recommended for destructive operations)
ansible webservers -m ansible.controller.credential -a "credential_type=Machine name=Team Name" -b --check --diff

# Apply the change
ansible webservers -m ansible.controller.credential -a "credential_type=Machine name=Team Name" -b --diff
```

### Examples from Ansible Documentation

```yaml
- name: Add machine credential
  credential:
    name: Team Name
    description: Team Description
    organization: test-org
    credential_type: Machine
    state: present
    controller_config_file: "~/tower_cli.cfg"

- name: Create a valid SCM credential from a private_key file
  credential:
    name: SCM Credential
    organization: Default
    state: present
    credential_type: Source Control
    inputs:
      username: joe
      password: secret
      ssh_key_data: "{{ lookup('file', '/tmp/id_rsa') }}"
      ssh_key_unlock: "passphrase"

- name: Fetch private key
  slurp:
    src: '$HOME/.ssh/aws-private.pem'
  register: aws_ssh_key

- name: Add Credential
  credential:
    name: Workshop Credential
    credential_type: Machine
    organization: Default
    inputs:
      ssh_key_data: "{{ aws_ssh_key['content'] | b64decode }}"
  run_once: true
  delegate_to: localhost

- name: Add Credential with Custom Credential Type
  credential:
    name: Workshop Credential
    credential_type: MyCloudCredential
    organization: Default
    controller_username: admin
    controller_password: ansible
    controller_host: https://localhost

- name: Create a Vault credential (example for notes)
  credential:
    name: Example password
    credential_type: Vault
    organization: Default
    inputs:
      vault_password: 'hello'
      vault_id: 'My ID'

- name: Bad password update (will replace vault_id)
  credential:
    name: Example password
    credential_type: Vault
    organization: Default
    inputs:
      vault_password: 'new_password'

- name: Another bad password update (will replace vault_id)
  credential:
    name: Example password
    credential_type: Vault
    organization: Default
    vault_password: 'new_password'

- name: A safe way to update a password and keep vault_id
  credential:
    name: Example password
    credential_type: Vault
    organization: Default
    inputs:
      vault_password: 'new_password'
      vault_id: 'My ID'

- name: Copy Credential
  credential:
    name: Copy password
    copy_from: Example password
    credential_type: Vault
    organization: Foo
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
ANSIBLE_STDOUT_CALLBACK=json ansible <hosts> -m ansible.controller.credential -a "<args>" -b
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
- Target a single host directly: `ansible <hostname>, -m ansible.controller.credential -a "..."` (note the trailing comma)
