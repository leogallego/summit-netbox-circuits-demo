# Red Hat Summit 2026 — NetBox Circuits Demo

Automated WAN circuit failover driven by **NetBox** as the Source of Truth and **Red Hat Ansible Automation Platform 2.6** as the automation engine, built for Red Hat Summit 2026.

A global enterprise runs WAN circuits across three sites — GB-Bristol, US-Atlanta, and AR-Buenos-Aires. A primary circuit goes down. With NetBox, Event-Driven Ansible, and Ansible Automation Platform, the entire failover — router reconfiguration, CMDB update, and incident report — happens in under 30 seconds with no manual intervention. Failback works the same way: set the other circuit offline, and automation reverses the route swap.

## Demo Flow

### 1. Set the scene

Open **NetBox Visual Explorer** and show the live topology — three sites, five circuits, routers at each location. Optionally, show the **Ansible Automation Platform** dashboard — the Circuit Failover Workflow is idle, waiting for events.

### 2. Trigger the failure

Tell **NetBox Copilot**:

> "IPLC-GB-AT-PRI has failed — set it to offline"

Copilot PATCHes the circuit status to `offline` via the NetBox API.

### 3. Event-Driven Ansible detects the change

The status change fires a **NetBox event rule** which sends a webhook. **Event-Driven Ansible** receives the event, evaluates the rulebook condition (circuit status is `offline` or `failed`), and automatically launches the **Circuit Failover Workflow** in Ansible Automation Platform — passing the circuit CID as an extra variable.

Switch to the **AAP UI** and show the workflow running in real time.

### 4. Ansible Automation Platform executes the workflow

**Workflow Step 1 — Circuit Failover** (`pb_circuit_failover.yml`):

- Queries NetBox for the failed circuit using the `netbox.netbox` Ansible collection and resolves its A-side (GB-Bristol) and Z-side (US-Atlanta) sites from circuit terminations
- Discovers all backup candidates with the `dd` tag present at both sites
- Selects the best backup by committed bandwidth (10 Gbps primary → 5 Gbps backup)
- Derives per-router gateways from NetBox: follows circuit → termination → cable → interface → IP, calculates the /30 peer address for each router independently
- Pushes failover routing config to Cisco routers via `cisco.ios.ios_config` (routers without a management IP in NetBox log a simulated stub instead)
- Updates NetBox via `netbox.netbox.netbox_circuit`: primary → `offline`, backup → `active`

**Workflow Step 2 — Deploy Report** (`pb_deploy_report.yml`):

- Re-queries NetBox for the current circuit state
- Generates a timestamped HTML incident report with topology diagram, bandwidth impact, per-router gateway config, failover timeline, audit trail, and recommended next steps
- Deploys the report to GitHub Pages and updates the report index page
- Each run produces a unique report file — previous reports are preserved and browsable

### 5. Watch the map update

Return to **Visual Explorer**. The failed circuit has disappeared from the map and the backup is now shown as active. The topology updated live as Ansible Automation Platform wrote back to NetBox.

### 6. Open the incident report

Open the report URL served by the report web server. The report shows the full incident summary: network topology SVG, which circuit failed, which backup was selected, bandwidth capacity degradation (50%), router config changes, a step-by-step failover timeline with timestamps showing each AAP workflow step, and direct links to the NetBox audit trail.

### 7. Confirm with Claude via MCP

Ask Claude (connected to NetBox and AAP via MCP servers):

> "What is the current status of IPLC-GB-AT-PRI?"

Claude queries NetBox directly through the **NetBox MCP server** and confirms the circuit is offline and the backup is active.

> "Show me the last workflow job that ran"

Claude queries AAP through the **AAP MCP server** and shows the workflow execution details — job status, timestamps, which playbooks ran, and the extra variables that were passed.

### 8. Reset for the next run

Run `./reset.sh` or launch the **Reset Demo** job template in AAP to restore all circuits to their starting state.

---

## Key Points

- **NetBox is the trigger, not a passive CMDB.** One status change in Copilot kicks off the entire automation chain via Event-Driven Ansible.
- **Event-Driven Ansible bridges NetBox and AAP.** The EDA rulebook listens for circuit events and launches the right workflow automatically — no polling, no manual intervention.
- **No hardcoded anything.** Backup circuits, gateways, and route direction are all derived dynamically from NetBox. Add a new circuit and it's automatically a candidate. Add a new site and the seed playbook picks it up.
- **Per-router gateway derivation.** Each router gets its own gateway from its own /30 interface IP — not a shared hardcoded value. Works correctly regardless of which side of the circuit the router is on.
- **Bidirectional failover/failback.** Set any circuit offline → automation activates the other and pushes the correct routes. Failback is just another failover in reverse.
- **Two-step workflow in AAP.** Circuit update and report deployment are separate, auditable steps — visible in Ansible Automation Platform's job history with full logs and timing.
- **Timestamped incident reports.** Every failover produces a unique report with per-router gateway details, published to GitHub Pages with an auto-generated index.
- **Visual Explorer updates live.** The map reflects the new topology immediately after Ansible Automation Platform writes back.
- **MCP servers close the loop.** Claude can query both NetBox (circuit status) and AAP (job execution history) directly — no UI required.

---

## Infrastructure

| Component | Details |
|---|---|
| NetBox | NetBox instance — circuits, devices, Visual Explorer, Copilot, event rules |
| Ansible Automation Platform 2.6 | Containerized (all-in-one or growth topology) — Automation Controller, Event-Driven Ansible, workflows, job templates |
| Report server | AWS EC2 t3.micro (eu-west-2), nginx HTTPS, SSH on port 2222 |
| NetBox MCP server | AWS EC2 t3.micro (eu-west-2), netboxlabs/netbox-mcp-server, SSH stdio |
| AAP MCP server | Ansible Automation Platform MCP server — queries jobs, workflows, inventories |

---

## Demo Topology

| Site | Router | Circuits |
|---|---|---|
| GB-Bristol | gb-rtr-01 | GB↔US PRI/SEC, AR↔GB |
| US-Atlanta (hub) | us-rtr-01 | GB↔US PRI/SEC, US↔AR PRI/SEC |
| AR-Buenos-Aires | ar-rtr-01 | US↔AR PRI/SEC, AR↔GB |

### Circuits

| CID | Path | Role | Starting State |
|---|---|---|---|
| `IPLC-GB-AT-PRI` | GB↔US | Primary (fails in demo) | active |
| `IPLC-GB-AT-SEC` | GB↔US | Backup (activated by automation) | offline |
| `IPLC-US-AR-PRI` | US↔AR | Primary | active |
| `IPLC-US-AR-SEC` | US↔AR | Backup | offline |
| `IPLC-AR-GB-01` | AR↔GB | Standalone (no backup) | active |

All demo objects are tagged `dd` in NetBox. This tag scopes all queries — backup discovery, reset, and report generation only touch `dd`-tagged objects. Each circuit termination is cabled to a router interface with an IP on a /30 point-to-point subnet — this wiring is how the playbook derives gateways dynamically.

Sites can be toggled when seeding: `./run-playbook.sh ansible/pb_seed_netbox.yml -e seed_buenos_aires=false`

### Failover / Failback Behavior

The automation is **bidirectional** — setting *any* circuit offline triggers failover to the other one. This means failback is just another failover in the opposite direction.

| Starting State | Action | EDA Triggers? | Result |
|---|---|---|---|
| PRI active, SEC offline | Set PRI offline | Yes | SEC activated, routes swapped |
| PRI offline, SEC active | Set SEC offline | Yes | PRI activated, routes swapped |
| Both active | Set PRI offline | Yes | SEC stays active, routes updated |
| Both active | Set SEC offline | Yes | PRI stays active, routes updated |
| Both offline | — | No | Deadlock — no backup available, playbook fails with assert |

**How it works:** the failover playbook queries all `dd`-tagged circuits at both sites regardless of status. It builds a backup candidate list by excluding the failed circuit, then selects the best candidate by committed bandwidth. If the candidate is already active, only the route swap happens — no redundant NetBox update.

**Gateway derivation:** each circuit termination is cabled to a router interface in NetBox, and each interface has an IP address on a /30 point-to-point subnet. The playbook follows the chain circuit → termination → cable → interface → IP, then derives the gateway as the first host in the /30. This makes route direction automatic — no hardcoded gateway mappings.

**Demo scenario:** set PRI offline → automation activates SEC. To fail back, set SEC offline → automation reactivates PRI. Reset with `./reset.sh` to restore starting state.

---

## Setup

See [SETUP.md](SETUP.md) for full setup instructions including AAP configuration, NetBox integration, and local testing.

---

## Repository layout

```
ansible/
  pb_setup_aap.yml          # Idempotent AAP + EDA + NetBox configuration playbook
  pb_circuit_failover.yml   # Workflow Step 1: find backup, derive gateways, push config, update NetBox
  pb_deploy_report.yml      # Workflow Step 2: generate timestamped report, publish to GitHub Pages
  pb_reset_demo.yml         # Reset all dd-tagged circuits to starting state
  pb_seed_netbox.yml        # Seed NetBox with demo data (sites, circuits, interfaces, IPs, cables)
  pb_launch_demo_router.yml # Launch CSR 1000v 16.12 on AWS for router testing
  pb_setup_local_netbox.yml # Deploy local NetBox via Podman for testing
  pb_setup_local_eda.yml    # Deploy local EDA environment for testing
  templates/
    failover_report.html.j2 # Jinja2 HTML report template (topology, gateways, timeline)
    report_index.html.j2    # Auto-generated index page listing all reports
    assets/                 # Red Hat and NetBox logos
  vars/
    demo_data.yml           # Single source of truth — circuits, sites, routers, IPs, wiring
    netbox_creds.yml        # Credentials via env vars (works with AAP injection)
    report.yml              # GitHub Pages and report server settings
  inventory/
    localhost.yml            # Localhost inventory for local execution
collections/
  requirements.yml          # netbox.netbox, cisco.ios, ansible.controller, ansible.eda, etc.
infra/
  main.tf                   # Terraform — EC2 report server + Cisco router
rulebooks/
  rulebook.yml              # EDA rulebook for Event-Driven Ansible
ansible-navigator.yml       # Project-wide navigator config (EE image, env passthrough)
run-playbook.sh             # Wrapper — sources .env, runs playbooks inside the EE
setup.sh / reset.sh         # Setup and reset helper scripts
DEMO.md                     # Full scenario and architecture reference
SETUP.md                    # Setup and configuration guide
```
