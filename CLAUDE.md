# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Red Hat Summit 2026 demo: automated WAN circuit failover driven by NetBox as the Source of Truth and Ansible Automation Platform 2.6 as the automation engine. When a circuit fails, a NetBox event rule fires a webhook to Event-Driven Ansible, which launches a three-step workflow on Automation Controller — failover (discover backup, update NetBox), router config push (apply routing changes via legacy-crypto EE), then report (generate and deploy an HTML incident report).

## Architecture

```
NetBox Copilot → PATCH circuit to offline
  → NetBox event rule → webhook to Event-Driven Ansible
  → EDA rulebook evaluates condition → launches workflow on Automation Controller
  → AAP "Circuit Failover Workflow":
      Step 1: pb_circuit_failover.yml (query NetBox, discover backup, update NetBox, pass router targets via set_stats)
      Step 2: pb_router_config.yml (push failover routing to real routers via cisco.ios — legacy-crypto EE)
      Step 3: pb_deploy_report.yml (re-query state, render Jinja2 HTML report, publish to GitHub Pages)
  → Visual Explorer updates live, report served on HTTPS
```

The playbook guards against spurious triggers — exits cleanly if the circuit is not actually offline/failed.

Backup discovery is dynamic: all circuits tagged `dd` present at both the A-side and Z-side sites are candidates, selected by highest committed bandwidth. No hardcoded backup mappings.

## Common Commands

```bash
# First-time setup
cp .env.example .env        # fill in credentials
./setup.sh                  # creates .env from .env.example
./run-playbook.sh ansible/pb_setup_aap.yml   # configures AAP + NetBox webhook (idempotent)
./setup_infra.sh            # provisions EC2 instances via Terraform (infra/)

# Run playbooks locally (sources .env, uses localhost inventory)
./run-playbook.sh ansible/pb_circuit_failover.yml
./run-playbook.sh ansible/pb_circuit_failover.yml --extra-vars "failed_circuit=IPLC-GB-AT-PRI"
./run-playbook.sh ansible/pb_deploy_report.yml --extra-vars "failed_circuit=IPLC-GB-AT-PRI"

# Local testing (no AAP needed)
ansible-playbook ansible/pb_setup_local_netbox.yml    # deploy NetBox via Podman
./run-playbook.sh ansible/pb_seed_netbox.yml          # seed demo data
./run-playbook.sh ansible/pb_setup_local_eda.yml -e test=true  # EDA with debug action

# Reset demo state between runs
./reset.sh

# Tear down AWS infrastructure
./teardown_infra.sh

# Generate slide deck
uv run --with Pillow --with python-pptx python slides/make_deck.py
```

## Credentials and Secrets

All secrets and infrastructure variables live in `.env` (gitignored). Playbooks read credentials via `ansible/vars/netbox_creds.yml` and `lookup('env', ...)` — either source `.env` locally or rely on AAP credential injection (NetBox credential type injects `NETBOX_API` + `NETBOX_TOKEN`).

Report settings and GitHub Pages credentials are in `ansible/vars/report.yml` — imported via `vars_files:` in `pb_deploy_report.yml`. GitHub credential type in AAP injects `GITHUB_TOKEN`, `GITHUB_REPO`, `GITHUB_REPORT_DIR` as env vars.

Infrastructure variables (`REPORT_SERVER_HOST`, `ROUTER_IP`, etc.) are written to `.env` by `setup_infra.sh` from Terraform outputs, or set manually.

## Key Design Decisions

- **Event-Driven Ansible as the event router**: NetBox event rule fires webhook to EDA, which evaluates the rulebook condition and launches the workflow on Automation Controller. Requires AAP 2.6 with `registry.redhat.io/ansible-automation-platform-26/de-supported-rhel9` Decision Environment.
- **netbox.netbox collection**: All NetBox interactions use `nb_lookup` (reads) and `netbox_circuit` (status updates). No raw `ansible.builtin.uri` API calls.
- **Split router config playbook**: Router config push runs as a separate workflow step (`pb_router_config.yml`) on the legacy-crypto EE. Receives router targets via `set_stats` from the failover step — no NetBox dependency. Routers without a management IP in NetBox get simulated debug output in the failover step instead.
- **Two Execution Environments**: Standard EE for NetBox queries and reports. Legacy-crypto EE (`quay.io/acme_corp/netbox-webinar-legacy-crypto-ee:latest`) with SHA-1 crypto policy overrides for IOS-XE < 17 routers. C8000v (IOS-XE 17.x) works with either EE.
- **Report server**: EC2 instance provisioned by Terraform, nginx with HTTPS, SSH on port 2222.
- **GitHub Pages as default report target**: The HTML failover report is published to the `gh-pages` branch root via the GitHub Contents API (`ansible.builtin.uri`). GitHub Pages serves it from the `gh-pages` branch. This keeps report artifacts off `main` so report deploys don't cause push conflicts. The SSH/EC2 report server is kept as a conditional fallback.
- **NetBox circuit tag `dd`**: All demo-relevant circuits are tagged `dd` in NetBox. This tag scopes all queries — backup discovery, reset, and report generation only touch `dd`-tagged circuits.
- **NetBox v4.5 token compatibility**: v2 tokens (default on NetBox 4.5+) work with pynetbox >= 7.6.0. The `netbox-summit-2026-ee` EE ships pynetbox 7.6.1. Pass the full `nbt_<key>.<token>` format.
- **Webhook body template**: Use empty body_template (NetBox default payload). Custom templates with `{{ data | tojson }}` fail on NetBox v4.5.
- **Always test with the EE**: Use `ansible-navigator` with `quay.io/acme_corp/netbox-summit-2026-ee:v3.22-3` for all local testing. Never use bare `ansible-playbook` on host Python — it bypasses the EE's pinned collections and Python dependencies, leading to version mismatches that don't reproduce on AAP.

## Demo Circuits

| CID | Role | Starting State |
|---|---|---|
| `IPLC-GB-AT-PRI` | Primary (fails in demo) | active |
| `IPLC-GB-AT-SEC` | Backup (activated by automation) | offline |

`reset.sh` / `pb_reset_demo.yml` restores this starting state.
