# GitHub Pages Report Deployment — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add GitHub Pages as the default report publishing target, keeping SSH as a conditional fallback.

**Architecture:** A new shared vars file (`ansible/vars/report.yml`) provides a single source of truth for report settings and GitHub credentials. A new Play 2 in `pb_deploy_report.yml` uses `ansible.builtin.slurp` + `ansible.builtin.uri` (GitHub Contents API) to push the generated HTML report to the repo's `docs/` directory. AAP gets a custom "GitHub" credential type that injects env vars for the playbook.

**Tech Stack:** Ansible (ansible.builtin.uri, ansible.builtin.slurp), GitHub Contents API, GitHub Pages, AAP 2.6 credential types

**Spec:** `docs/superpowers/specs/2026-05-04-github-pages-report-design.md`

---

## File Map

| Action | File | Purpose |
|--------|------|---------|
| Create | `ansible/vars/report.yml` | Shared vars: report_filename, github_token, github_repo, github_report_dir |
| Create | `docs/.nojekyll` | Empty file — disables Jekyll on GitHub Pages |
| Create | `docs/index.html` | Placeholder landing page for GitHub Pages |
| Modify | `ansible/pb_deploy_report.yml` | Add GitHub Pages publish play (Play 2), import shared vars in all plays |
| Modify | `ansible/pb_setup_aap.yml` | Add GitHub credential type + credential + conditional JT attachment |
| Modify | `.env.example` | Add REPORT_FILENAME, GITHUB_TOKEN, GITHUB_REPO, GITHUB_REPORT_DIR |
| Modify | `CLAUDE.md` | Update architecture diagram and design decisions |

---

### Task 1: Create shared vars file (`ansible/vars/report.yml`)

**Files:**
- Create: `ansible/vars/report.yml`

- [ ] **Step 1: Create the vars file**

```yaml
---
report_filename: "{{ lookup('env', 'REPORT_FILENAME') | default('failover_report_collection.html', true) }}"
github_token: "{{ lookup('env', 'GITHUB_TOKEN') | default('', true) }}"
github_repo: "{{ lookup('env', 'GITHUB_REPO') | default('leogallego/summit-netbox-circuits-demo', true) }}"
github_report_dir: "{{ lookup('env', 'GITHUB_REPORT_DIR') | default('docs', true) }}"
```

- [ ] **Step 2: Commit**

```bash
git add ansible/vars/report.yml
git commit -m "feat: add shared report vars file (issue #26)

Single source of truth for report_filename and GitHub Pages
settings. Each variable reads from its env var with a sensible
default.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 2: Create GitHub Pages static files

**Files:**
- Create: `docs/.nojekyll`
- Create: `docs/index.html`

- [ ] **Step 1: Create `docs/.nojekyll`**

Empty file (zero bytes). This tells GitHub Pages to skip Jekyll processing and serve raw HTML.

- [ ] **Step 2: Create `docs/index.html`**

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Circuit Failover Reports</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 640px; margin: 4rem auto; padding: 0 1rem; color: #333; }
    h1 { font-size: 1.4rem; }
    p { color: #666; }
  </style>
</head>
<body>
  <h1>Circuit Failover Reports</h1>
  <p>No failover report generated yet. Run the Circuit Failover Workflow to publish a report here.</p>
</body>
</html>
```

- [ ] **Step 3: Commit**

```bash
git add docs/.nojekyll docs/index.html
git commit -m "feat: add GitHub Pages scaffolding (issue #26)

.nojekyll disables Jekyll processing. index.html is a placeholder
landing page until a failover report is published.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 3: Update `.env.example` with new variables

**Files:**
- Modify: `.env.example`

- [ ] **Step 1: Add report and GitHub Pages variables**

Append the following block at the end of `.env.example`, after the existing `PRIVATE_KEY_PATH=` line:

```
# Report settings
REPORT_FILENAME=failover_report_collection.html

# GitHub Pages report publishing (optional — leave empty to skip)
# Token needs contents:write scope on the target repo.
GITHUB_TOKEN=
GITHUB_REPO=leogallego/summit-netbox-circuits-demo
GITHUB_REPORT_DIR=docs
```

- [ ] **Step 2: Commit**

```bash
git add .env.example
git commit -m "feat: add GitHub Pages env vars to .env.example (issue #26)

Adds REPORT_FILENAME, GITHUB_TOKEN, GITHUB_REPO, and
GITHUB_REPORT_DIR with comments explaining each.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 4: Modify `pb_deploy_report.yml` — import shared vars and add GitHub Pages play

This is the main playbook change. The playbook goes from 3 plays to 4 plays:

1. Generate HTML report (existing — modified to use shared vars)
2. **Publish to GitHub Pages (NEW)**
3. Register report server (existing — modified to use shared vars)
4. Publish to web server via SSH (existing — unchanged)

**Files:**
- Modify: `ansible/pb_deploy_report.yml:17-28` (Play 1 vars)
- Modify: `ansible/pb_deploy_report.yml:180-204` (Play 2 → Play 3 vars)
- Insert new Play 2 between current Play 1 and Play 2

- [ ] **Step 1: Update Play 1 — replace hardcoded `report_filename` with shared vars import**

In the first play (line 17–178), make two changes:

1. Add `vars/report.yml` to `vars_files:` (after `vars/netbox_creds.yml`)
2. Remove `report_filename` from the `vars:` block (keep `failed_circuit` and `report_dir`)

Before:
```yaml
  vars_files:
    - vars/netbox_creds.yml

  vars:
    failed_circuit: "IPLC-GB-AT-PRI"
    report_filename: "failover_report_collection.html"
    report_dir: "{{ playbook_dir }}/reports"
```

After:
```yaml
  vars_files:
    - vars/netbox_creds.yml
    - vars/report.yml

  vars:
    failed_circuit: "IPLC-GB-AT-PRI"
    report_dir: "{{ playbook_dir }}/reports"
```

- [ ] **Step 2: Insert new Play 2 — Publish to GitHub Pages**

Insert this entire play between the current Play 1 (ends at line 178) and the current Play 2 (starts at line 180 "Register report server for publishing"). This play is conditional on `github_token` being non-empty.

```yaml
# ── Play 2: Publish report to GitHub Pages (if configured) ──────────────────

- name: Publish failover report to GitHub Pages
  hosts: localhost
  connection: local
  gather_facts: false

  vars_files:
    - vars/report.yml

  vars:
    report_dir: "{{ playbook_dir }}/reports"

  tasks:
    - name: Skip if no GitHub token configured
      ansible.builtin.meta: end_play
      when: github_token | length == 0

    - name: Read generated report file
      ansible.builtin.slurp:
        src: "{{ report_dir }}/{{ report_filename }}"
      register: report_content

    - name: Check if report already exists on GitHub
      ansible.builtin.uri:
        url: "https://api.github.com/repos/{{ github_repo }}/contents/{{ github_report_dir }}/{{ report_filename }}"
        method: GET
        headers:
          Authorization: "Bearer {{ github_token }}"
          Accept: "application/vnd.github.v3+json"
        status_code:
          - 200
          - 404
      register: github_existing_file

    - name: Set file SHA for update
      ansible.builtin.set_fact:
        github_file_sha: "{{ github_existing_file.json.sha | default('') }}"
      when: github_existing_file.status == 200

    - name: Set empty SHA for first deploy
      ansible.builtin.set_fact:
        github_file_sha: ""
      when: github_existing_file.status == 404

    - name: Build request body for GitHub Contents API
      ansible.builtin.set_fact:
        github_put_body: >-
          {{
            {
              'message': 'Update failover report',
              'content': report_content.content
            }
            | combine(
                {'sha': github_file_sha}
                if github_file_sha | length > 0
                else {}
              )
          }}

    - name: Push report to GitHub repository
      ansible.builtin.uri:
        url: "https://api.github.com/repos/{{ github_repo }}/contents/{{ github_report_dir }}/{{ report_filename }}"
        method: PUT
        headers:
          Authorization: "Bearer {{ github_token }}"
          Accept: "application/vnd.github.v3+json"
        body_format: json
        body: "{{ github_put_body }}"
        status_code:
          - 200
          - 201
      register: github_push_result

    - name: Report published to GitHub Pages
      ansible.builtin.debug:
        msg: >-
          Report published to GitHub Pages:
          https://{{ github_repo | regex_replace('/', '.github.io/') }}/{{ report_filename }}
        verbosity: 0
```

- [ ] **Step 3: Update Play 3 (formerly Play 2) — replace hardcoded `report_filename` with shared vars import**

In the "Register report server for publishing" play (currently line 180), make two changes:

1. Add `vars_files:` with `vars/report.yml`
2. Remove `report_filename` from the `vars:` block

Before:
```yaml
- name: Register report server for publishing
  hosts: localhost
  gather_facts: false

  vars:
    report_server_host: "{{ lookup('env', 'REPORT_SERVER_HOST') }}"
    report_server_port: "{{ lookup('env', 'REPORT_SERVER_PORT') | default('2222', true) }}"
    report_url: "{{ lookup('env', 'REPORT_URL') }}"
    report_filename: "failover_report_collection.html"
```

After:
```yaml
- name: Register report server for publishing
  hosts: localhost
  gather_facts: false

  vars_files:
    - vars/report.yml

  vars:
    report_server_host: "{{ lookup('env', 'REPORT_SERVER_HOST') }}"
    report_server_port: "{{ lookup('env', 'REPORT_SERVER_PORT') | default('2222', true) }}"
    report_url: "{{ lookup('env', 'REPORT_URL') }}"
```

- [ ] **Step 4: Verify Play 4 (SSH publish) needs no changes**

The final play ("Publish failover report to web server") references `report_filename` from host vars set in Play 3's `add_host` task. It does not hardcode `report_filename`, so no changes needed.

- [ ] **Step 5: Commit**

```bash
git add ansible/pb_deploy_report.yml
git commit -m "feat: add GitHub Pages publishing play to deploy report (issue #26)

Play 1 and Play 3 now import vars/report.yml instead of
hardcoding report_filename. New Play 2 publishes the HTML report
to the repo's docs/ directory via the GitHub Contents API,
conditional on GITHUB_TOKEN being set. SSH path unchanged.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 5: Modify `pb_setup_aap.yml` — add GitHub credential type and conditional attachment

**Files:**
- Modify: `ansible/pb_setup_aap.yml:92` (add vars)
- Modify: `ansible/pb_setup_aap.yml:128-166` (after NetBox credential, add GitHub credential type + credential)
- Modify: `ansible/pb_setup_aap.yml:276-295` (Deploy Report JT — conditional credential list)

- [ ] **Step 1: Add GitHub-related vars to the play vars block**

After line 92 (`report_filename: "failover_report_collection.html"`), add:

```yaml
    github_token: "{{ lookup('env', 'GITHUB_TOKEN') | default('', true) }}"
    github_repo: "{{ lookup('env', 'GITHUB_REPO') | default('leogallego/summit-netbox-circuits-demo', true) }}"
    github_report_dir: "{{ lookup('env', 'GITHUB_REPORT_DIR') | default('docs', true) }}"
    github_cred_name: "{{ aap_org_name }} GitHub"
```

- [ ] **Step 2: Add GitHub credential type and credential tasks**

Insert these two tasks after the NetBox credential task (after line 166, before the Container Registry credential). Follow the exact pattern used by the NetBox credential type at lines 128-166.

```yaml
    # ── Controller: GitHub credential type ──────────────────────────────────

    - name: Create GitHub credential type
      ansible.controller.credential_type:
        name: "GitHub"
        kind: cloud
        inputs:
          fields:
            - id: GITHUB_TOKEN
              type: string
              label: "Personal Access Token"
              secret: true
            - id: GITHUB_REPO
              type: string
              label: "Repository (owner/name)"
            - id: GITHUB_REPORT_DIR
              type: string
              label: "Report directory in repo"
          required:
            - GITHUB_TOKEN
            - GITHUB_REPO
        injectors:
          env:
            GITHUB_TOKEN: "{{ '{{' }} GITHUB_TOKEN {{ '}}' }}"
            GITHUB_REPO: "{{ '{{' }} GITHUB_REPO {{ '}}' }}"
            GITHUB_REPORT_DIR: "{{ '{{' }} GITHUB_REPORT_DIR {{ '}}' }}"
        state: present
      when: github_token | length > 0
      tags:
        - credentials

    # ── Controller: GitHub credential ─────────────────────────────────────────

    - name: Create GitHub credential
      ansible.controller.credential:
        name: "{{ github_cred_name }}"
        organization: "{{ aap_org_name }}"
        credential_type: "GitHub"
        inputs:
          GITHUB_TOKEN: "{{ github_token }}"
          GITHUB_REPO: "{{ github_repo }}"
          GITHUB_REPORT_DIR: "{{ github_report_dir }}"
        state: present
      when: github_token | length > 0
      tags:
        - credentials
```

- [ ] **Step 3: Update Deploy Report job template — build credentials list dynamically**

Replace the existing "Create Deploy Report job template" task (lines 276-295) so the credentials list includes the GitHub credential conditionally:

Before:
```yaml
    - name: Create Deploy Report job template
      ansible.controller.job_template:
        name: "{{ jt_report_name }}"
        organization: "{{ aap_org_name }}"
        inventory: "{{ inventory_name }}"
        project: "{{ controller_project_name }}"
        playbook: "ansible/pb_deploy_report.yml"
        execution_environment: "{{ ee_name }}"
        job_type: run
        ask_variables_on_launch: true
        extra_vars:
          failed_circuit: "IPLC-GB-PH-PRI"
        credentials:
          - "{{ netbox_cred_name }}"
        description: >-
          Generates and deploys the HTML failover report
          to the report web server.
        state: present
      tags:
        - job_templates
```

After:
```yaml
    - name: Create Deploy Report job template
      ansible.controller.job_template:
        name: "{{ jt_report_name }}"
        organization: "{{ aap_org_name }}"
        inventory: "{{ inventory_name }}"
        project: "{{ controller_project_name }}"
        playbook: "ansible/pb_deploy_report.yml"
        execution_environment: "{{ ee_name }}"
        job_type: run
        ask_variables_on_launch: true
        extra_vars:
          failed_circuit: "IPLC-GB-PH-PRI"
        credentials: >-
          {{
            [netbox_cred_name]
            + ([github_cred_name] if github_token | length > 0 else [])
          }}
        description: >-
          Generates and deploys the HTML failover report.
          Publishes to GitHub Pages when GitHub credential is configured.
        state: present
      tags:
        - job_templates
```

- [ ] **Step 4: Update the summary debug task**

In the summary debug task at the end of the playbook (line 764+), add the GitHub credential to the output. After the `NetBox Cred:` line, add:

```
              {{ 'GitHub Cred:     ' ~ github_cred_name if github_token | length > 0 else 'GitHub Cred:     (not configured — report published locally only)' }}
```

- [ ] **Step 5: Commit**

```bash
git add ansible/pb_setup_aap.yml
git commit -m "feat: add GitHub credential type and attachment to AAP setup (issue #26)

Custom 'GitHub' credential type injects GITHUB_TOKEN, GITHUB_REPO,
and GITHUB_REPORT_DIR as env vars. Credential and JT attachment
are conditional on GITHUB_TOKEN being set in .env.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 6: Update `CLAUDE.md` — architecture and design decisions

**Files:**
- Modify: `CLAUDE.md:12-18` (architecture diagram)
- Modify: `CLAUDE.md:64-65` (design decisions)

- [ ] **Step 1: Update architecture diagram**

Replace line 17 in the architecture block:

Before:
```
      Step 2: pb_deploy_report.yml (re-query state, render Jinja2 HTML report, deploy to report server via SSH)
```

After:
```
      Step 2: pb_deploy_report.yml (re-query state, render Jinja2 HTML report, publish to GitHub Pages and/or deploy to report server via SSH)
```

- [ ] **Step 2: Add GitHub Pages design decision**

After the `- **Report server**:` bullet (line 65), add a new bullet:

```markdown
- **GitHub Pages as default report target**: The HTML failover report is published to the repo's `docs/` directory via the GitHub Contents API (`ansible.builtin.uri`). GitHub Pages serves it from the `main` branch `/docs` path. The SSH/EC2 report server is kept as a conditional fallback.
```

- [ ] **Step 3: Update the Credentials and Secrets section**

After the existing paragraph about `ansible/vars/netbox_creds.yml` (line 56), add:

```markdown
Report settings and GitHub Pages credentials are in `ansible/vars/report.yml` — imported via `vars_files:` in `pb_deploy_report.yml`. GitHub credential type in AAP injects `GITHUB_TOKEN`, `GITHUB_REPO`, `GITHUB_REPORT_DIR` as env vars.
```

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for GitHub Pages report publishing (issue #26)

Updates architecture diagram, adds GitHub Pages design decision,
and documents the new report.yml vars file.

Assisted-by: <model> <noreply@anthropic.com>"
```

---

### Task 7: Final verification

- [ ] **Step 1: Verify all files are syntactically valid**

```bash
cd /home/lgallego/Claude/summit-netbox-circuits-demo
python -c "import yaml; yaml.safe_load(open('ansible/vars/report.yml'))" && echo "report.yml OK"
python -c "
import yaml
with open('ansible/pb_deploy_report.yml') as f:
    docs = list(yaml.safe_load_all(f))
    print(f'pb_deploy_report.yml: {len(docs)} plays OK')
"
python -c "
import yaml
with open('ansible/pb_setup_aap.yml') as f:
    docs = list(yaml.safe_load_all(f))
    print(f'pb_setup_aap.yml: {len(docs)} plays OK')
"
```

Expected: All three files parse without errors. `pb_deploy_report.yml` should report 4 plays.

- [ ] **Step 2: Verify no hardcoded `report_filename` remains in plays that should use the shared var**

```bash
grep -n 'report_filename:.*failover_report' ansible/pb_deploy_report.yml
```

Expected: No output (the hardcoded values have been removed from Play 1 and Play 3).

- [ ] **Step 3: Verify `docs/` scaffolding**

```bash
test -f docs/.nojekyll && echo ".nojekyll exists" || echo "MISSING .nojekyll"
test -f docs/index.html && echo "index.html exists" || echo "MISSING index.html"
```

Expected: Both files exist.

- [ ] **Step 4: Check git status is clean**

```bash
git status
```

Expected: Working tree clean, all changes committed across Tasks 1–6.
