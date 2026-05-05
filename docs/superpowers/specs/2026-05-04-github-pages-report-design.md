# Deploy Failover Report to GitHub Pages Instead of SSH Server

**Issue:** #26
**Date:** 2026-05-04
**Status:** Approved

## Summary

Replace the SSH-based report deployment (EC2 + nginx) with GitHub Pages as the default publishing target. The generated HTML failover report is pushed to a `docs/` directory in this repo via the GitHub Contents API. The SSH path is kept as a conditional fallback.

## Report URL

`https://leogallego.github.io/summit-netbox-circuits-demo/<report_filename>`

Derived at runtime from `GITHUB_REPO` and the existing `report_filename` variable.

## Shared Variables File (`ansible/vars/report.yml`)

New vars file providing a single source of truth for report and GitHub settings. Imported via `vars_files:` in each play that needs these values. Each variable reads from its corresponding env var (set in `.env` locally, or injected by AAP credentials).

```yaml
report_filename: "{{ lookup('env', 'REPORT_FILENAME') | default('failover_report_collection.html', true) }}"
github_token: "{{ lookup('env', 'GITHUB_TOKEN') | default('', true) }}"
github_repo: "{{ lookup('env', 'GITHUB_REPO') | default('leogallego/summit-netbox-circuits-demo', true) }}"
github_report_dir: "{{ lookup('env', 'GITHUB_REPORT_DIR') | default('docs', true) }}"
```

This eliminates the duplicated `report_filename` declarations across plays. Each play adds `vars/report.yml` to its `vars_files:` list.

## Playbook Structure (`pb_deploy_report.yml`)

Four plays, executed in order:

### Play 1: Generate HTML report

Remove the hardcoded `report_filename` from play vars. Add `vars/report.yml` to `vars_files:`. Everything else stays as-is.

### Play 2: Publish to GitHub Pages (new)

Conditional on `github_token` being set (non-empty). Imports `vars/report.yml`. Steps:

1. **Slurp** the generated HTML file (`ansible.builtin.slurp`) to get base64-encoded content.
2. **GET** current file SHA from GitHub Contents API:
   - `GET /repos/{{ github_repo }}/contents/{{ github_report_dir }}/{{ report_filename }}`
   - `Authorization: Bearer {{ github_token }}`
   - Register result. Handle 404 (first deploy) by setting SHA to empty.
3. **PUT** file to GitHub Contents API:
   - `PUT /repos/{{ github_repo }}/contents/{{ github_report_dir }}/{{ report_filename }}`
   - Body: `{ "message": "Update failover report — <circuit_cid>", "content": "<base64>", "sha": "<sha_or_omit>" }`
   - Include `sha` field only when updating an existing file. On first deploy (GET returned 404), omit the `sha` field entirely — do not send an empty string.
4. **Print** the GitHub Pages URL.

### Play 3: Register report server

Remove the hardcoded `report_filename` from play vars. Add `vars/report.yml` to `vars_files:`. Conditional on `REPORT_SERVER_HOST` (unchanged).

### Play 4: Publish to web server via SSH (unchanged)

Runs against `report_servers` group (only populated if Play 3 ran).

### Fallback behavior

If neither `GITHUB_TOKEN` nor `REPORT_SERVER_HOST` is set, only the local file is generated and its path is printed. No publishing occurs.

## Environment Variables

Added to `.env.example`:

```
# Report settings
REPORT_FILENAME=failover_report_collection.html

# GitHub Pages report publishing (optional — leave empty to skip)
# Token needs contents:write scope on the target repo.
GITHUB_TOKEN=
GITHUB_REPO=leogallego/summit-netbox-circuits-demo
GITHUB_REPORT_DIR=docs
```

- `REPORT_FILENAME`: Name of the generated HTML report file. Defaults to `failover_report_collection.html`.
- `GITHUB_TOKEN`: GitHub Personal Access Token with `contents:write` scope.
- `GITHUB_REPO`: Target repository in `owner/name` format. Defaults to this repo but can point elsewhere.
- `GITHUB_REPORT_DIR`: Directory in the repo where the report is published. Defaults to `docs`.

## AAP Credential Configuration (`pb_setup_aap.yml`)

### Custom credential type

A "GitHub" credential type following the NetBox pattern:

```yaml
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
    GITHUB_TOKEN: "{{ GITHUB_TOKEN }}"
    GITHUB_REPO: "{{ GITHUB_REPO }}"
    GITHUB_REPORT_DIR: "{{ GITHUB_REPORT_DIR }}"
```

### Credential instance

Created conditionally when `GITHUB_TOKEN` is set in `.env`:

```yaml
name: "GitHub (Summit Demo)"
credential_type: "GitHub"
inputs:
  GITHUB_TOKEN: "{{ lookup('env', 'GITHUB_TOKEN') }}"
  GITHUB_REPO: "{{ lookup('env', 'GITHUB_REPO') | default('leogallego/summit-netbox-circuits-demo', true) }}"
  GITHUB_REPORT_DIR: "{{ lookup('env', 'GITHUB_REPORT_DIR') | default('docs', true) }}"
```

### Job template attachment

The GitHub credential is attached to the Deploy Report job template **conditionally** — only when `GITHUB_TOKEN` is set. The credentials list is built dynamically:

- Always: NetBox credential
- Conditionally: GitHub credential (when `GITHUB_TOKEN` is set)

## Repository Setup for GitHub Pages

### New files in repo

- **`docs/.nojekyll`**: Empty file. Prevents Jekyll processing so GitHub Pages serves raw HTML.
- **`docs/index.html`**: Placeholder page with "No failover report generated yet" message. Designed to eventually list multiple report runs (the structure supports adding links to historical reports later).

### GitHub Pages configuration

Enable GitHub Pages on the repo: serve from `main` branch, `/docs` directory. This is a one-time repo setting — documented in setup instructions, can also be enabled via:

```bash
gh api repos/leogallego/summit-netbox-circuits-demo/pages \
  --method POST \
  --field source='{"branch":"main","path":"/docs"}'
```

## Documentation Updates

- **`.env.example`**: Add `GITHUB_TOKEN`, `GITHUB_REPO`, `GITHUB_REPORT_DIR` with comments.
- **`CLAUDE.md`**: Update architecture diagram and key design decisions to mention GitHub Pages as the default report target.

## What Stays Unchanged

- Play 1 (report generation) — untouched.
- SSH deployment path (Plays 3-4) — kept as conditional fallback.
- Terraform infrastructure — no changes (cleanup is a separate issue).
- `reset.sh` — no changes needed (report is overwritten on each deploy).
- Report template (`failover_report.html.j2`) — untouched.
- `report_filename` value — same default, now sourced from `vars/report.yml` instead of hardcoded per-play.
