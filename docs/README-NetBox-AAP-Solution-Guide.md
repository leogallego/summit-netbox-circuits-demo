# Automated WAN Circuit Failover with NetBox and Ansible Automation Platform - Solution Guide

![NetBox + AAP Solution Guide](https://www.ansible.com/hubfs/Images/Ansible-Mark-Large-RGB-Pool.png)

## Overview

### Problem Statement

Enterprise WAN circuit failures trigger a cascade of manual steps: an engineer must detect the outage, identify a backup path, reconfigure routers, update the CMDB, and produce an incident report. This process typically takes 30-60 minutes per incident, during which business-critical traffic is down. For organizations with dozens of circuits across multiple geographies, even a single missed step — an outdated CMDB entry, a forgotten router — can compound into extended outages and compliance gaps.

This guide demonstrates how to **eliminate manual intervention in WAN circuit failover** by combining **NetBox** as the network source of truth with **Ansible Automation Platform (AAP) 2.6** and **Event-Driven Ansible (EDA)**. When a circuit status changes in NetBox, automation discovers the best backup, reconfigures routers, updates the CMDB, and publishes an incident report — all within 30 seconds.

> **This guide covers three use cases of increasing maturity:**
>
> - **Use Case A:** Event-driven circuit failover — NetBox status change triggers automatic backup discovery, router reconfiguration, and CMDB update
> - **Use Case B:** Automated incident reporting — failover events generate and publish timestamped HTML reports with topology diagrams and audit trails
> - **Use Case C:** Full closed-loop operations — combining failover, reporting, and automated failback into a self-healing WAN

### Table of Contents

- [Background](#background)
- [Solution](#solution)
  - [Components](#components)
  - [Who Benefits](#who-benefits)
  - [Demos, Videos, and Labs](#demos-videos-and-labs)
- [Prerequisites](#prerequisites)
  - [AAP Version](#aap-version)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [Workflow and Architecture](#workflow-and-architecture)
  - [Workflow Diagram](#workflow-diagram)
  - [Narrative Walkthrough](#narrative-walkthrough)
- [Solution Walkthrough](#solution-walkthrough)
  - [Use Case A: Event-Driven Circuit Failover](#use-case-a-event-driven-circuit-failover)
  - [Use Case B: Automated Incident Reporting](#use-case-b-automated-incident-reporting)
  - [Use Case C: Closed-Loop Failback](#use-case-c-closed-loop-failback)
- [Validation](#validation)
  - [Testing the End-to-End Pipeline](#testing-the-end-to-end-pipeline)
  - [Expected Results](#expected-results)
  - [Troubleshooting Common Failures](#troubleshooting-common-failures)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)

---

## Background

Modern enterprise WANs rely on redundant circuits between sites to maintain availability. When a primary circuit fails, traffic must be rerouted to a backup path. The challenge is not the routing change itself — it is the **coordination across systems**: the network source of truth must reflect the new state, routers must be reconfigured, stakeholders must be notified, and an audit trail must be maintained.

**NetBox** is an open-source network source of truth and CMDB that models circuits, sites, devices, interfaces, and their interconnections. It provides a REST API, webhooks, and event rules that make it an ideal trigger source for network automation.

**Event-Driven Ansible (EDA)** is a component of Ansible Automation Platform that listens for events from external systems — including NetBox webhooks — and evaluates rulebook conditions to decide which automation to trigger. EDA bridges the gap between "something changed" and "do something about it."

**Ansible Automation Platform (AAP) 2.6** provides the workflow engine, credential management, RBAC, and execution environments needed to run production automation at scale. Workflow templates chain multiple job templates into multi-step operations with error handling and conditional logic.

> **Why NetBox as the trigger source?**
>
> Unlike monitoring systems that detect symptoms (link down, packet loss), NetBox captures **intent**: an operator or upstream system declares a circuit offline. This intent-based trigger eliminates false positives from transient network events and ensures automation acts on authoritative state changes.

---

## Solution

### Components

- **[NetBox](https://netboxlabs.com/)** — Network source of truth and CMDB. Stores circuits, sites, devices, interfaces, IP addresses, and cables. Fires webhooks on state changes via event rules.

- **[Ansible Automation Platform 2.6](https://www.redhat.com/en/technologies/management/ansible)** — Enterprise automation platform providing Automation Controller (workflow engine, RBAC, credentials) and Event-Driven Ansible (event routing, rulebook evaluation).

- **[netbox.netbox Collection](https://console.redhat.com/ansible/automation-hub/repo/published/netbox/netbox/)** — Certified Ansible content collection for NetBox API interactions. Provides `nb_lookup` plugin for queries and resource modules (`netbox_circuit`, `netbox_device`, etc.) for state management.

- **[cisco.ios Collection](https://console.redhat.com/ansible/automation-hub/repo/published/cisco/ios/)** — Certified collection for Cisco IOS/IOS-XE device management. Provides `ios_config` and `ios_command` modules for router configuration.

- **[ansible.eda Collection](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/)** — EDA source and action plugins. Provides `webhook` source for receiving HTTP events and `run_workflow_template` action for triggering AAP workflows.

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| Network Engineer / SRE | Manually detecting circuit failures, identifying backups, reconfiguring routers, and updating the CMDB under time pressure | Automated failover completes in <30 seconds with full CMDB consistency. Engineers focus on root cause analysis instead of emergency reconfiguration |
| Network Architect | No systematic way to ensure backup selection follows capacity planning rules (highest bandwidth first) across a multi-site topology | Backup discovery is dynamic and policy-driven: automation queries all available circuits at both sites and selects by committed bandwidth. Adding new circuits to NetBox automatically includes them in failover candidates |
| IT Manager / Director | Circuit outage reports are inconsistent, delayed, and lack audit trails. Compliance requires proof of automated response times and decision rationale | Every failover produces a timestamped HTML report with topology diagrams, bandwidth impact analysis, backup selection rationale, and NetBox audit trail links — published automatically to GitHub Pages or an internal report server |

### Demos, Videos, and Labs

- **[Source Code Repository](https://github.com/leogallego/summit-netbox-circuits-demo)** — Full source code for all playbooks, rulebooks, templates, and infrastructure-as-code
- **[EDA + NetBox Workshop](https://github.com/redhat-zt/zt-ans-bu-eda-netbox)** — Hands-on interactive workshop with 7 progressive lab modules covering AAP dynamic inventory, EDA rulebooks, and NetBox integration

---

## Prerequisites

### AAP Version

**Ansible Automation Platform 2.6** (minimum). EDA requires the unified platform with Automation Decisions. The Decision Environment must be `registry.redhat.io/ansible-automation-platform-26/de-supported-rhel9:latest` or a custom DE based on it.

> **AAP 2.5 is also supported** for the workshop use cases (dynamic inventory, basic EDA rulebooks). Circuit failover with `run_workflow_template` requires AAP 2.5+ with the EDA controller component.

### Featured Ansible Content Collections

| Collection | Minimum Version | Type | Purpose |
|------------|----------------|------|---------|
| [netbox.netbox](https://console.redhat.com/ansible/automation-hub/repo/published/netbox/netbox/) | 3.19.0 | Certified | NetBox API queries (`nb_lookup`), resource management (`netbox_circuit`, `netbox_device`, `netbox_cable`) |
| [ansible.eda](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/) | 2.11.0 | Certified | EDA webhook source plugin, `run_workflow_template` and `run_job_template` actions |
| [ansible.controller](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/) | 4.7.0 | Certified | AAP resource configuration (job templates, workflows, credentials, inventories) |
| [cisco.ios](https://console.redhat.com/ansible/automation-hub/repo/published/cisco/ios/) | 9.0.0 | Certified | Cisco IOS-XE router configuration (`ios_config`, `ios_command`) |
| [ansible.utils](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/utils/) | 5.1.0 | Certified | IP address math (`ipaddr` filter) for gateway derivation from /30 subnets |
| [ansible.netcommon](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/netcommon/) | 7.1.0 | Certified | Network connection plugins and utilities |

### External Systems

| System | Required / Optional | Details |
|--------|-------------------|---------|
| NetBox | Required | v4.x+ recommended. Hosts circuit, site, device, interface, IP, and cable data. Must have webhook and event rule support enabled. |
| Cisco IOS-XE Router | Optional | For real router configuration. CSR 1000v 16.12+ or Catalyst 8000v. Without a router, failover runs in simulated mode with debug output. |
| GitHub Pages | Optional | Default target for HTML incident reports. Requires a GitHub token with repo write access. Falls back to an SSH-accessible report server. |
| AWS | Optional | For provisioning demo infrastructure (report server, router instances) via Terraform or Ansible. |

### Guide Metadata

- **Operational Impact:** Medium — automation modifies circuit status in NetBox and pushes routing configuration to network devices. Test in a non-production NetBox instance first.
- **Business Value Drivers:**
  - Reduce circuit failover time from 30-60 minutes to <30 seconds
  - Eliminate manual CMDB updates that lead to configuration drift
  - Produce audit-ready incident reports automatically for every failover event
- **Technical Value Drivers:**
  - Event-driven architecture eliminates polling and manual triggers
  - Dynamic backup discovery scales with topology changes — no hardcoded mappings
  - Per-router gateway derivation from NetBox cable data ensures configuration accuracy

---

## Workflow and Architecture

### Workflow Diagram

**Event-Driven Circuit Failover Pipeline:**

```
NetBox Copilot / UI              NetBox                    Event-Driven Ansible           Automation Controller
─────────────────────     ──────────────────────     ──────────────────────────     ──────────────────────────

 "Set IPLC-GB-AT-PRI       PATCH circuit status         Webhook received               Workflow launched
  to offline"              to 'offline'                 Condition matched:             ┌──────────────────┐
       │                        │                       status in [offline,failed]     │ Step 1: Failover │
       └───────────────────────►│                            │                        │  - Query NetBox   │
                                │   Event rule fires         │                        │  - Find backup    │
                                │   webhook to EDA           │                        │  - Push router    │
                                └───────────────────────────►│                        │    config         │
                                                             │  run_workflow_template  │  - Update NetBox  │
                                                             └───────────────────────►│                  │
                                                                                      ├──────────────────┤
                                                                                      │ Step 2: Report   │
                                                                                      │  - Query state    │
                                                                                      │  - Render HTML    │
                                                                                      │  - Publish to     │
                                                                                      │    GitHub Pages   │
                                                                                      └──────────────────┘
```

### Narrative Walkthrough

An operator (or NetBox Copilot) sets a circuit's status to `offline` in NetBox. NetBox evaluates its event rules and fires a webhook to Event-Driven Ansible, passing the circuit data payload. EDA's rulebook matches the condition — `status.value in ["offline", "failed"]` — and triggers the "Circuit Failover Workflow" on Automation Controller, passing the circuit ID (`cid`) as an extra variable.

The workflow executes two steps. **Step 1** (failover) queries NetBox for the failed circuit's termination sites, discovers all backup circuits tagged `dd` between those sites, selects the best candidate by highest committed bandwidth, derives per-router gateway IPs from NetBox cable wiring data, pushes failover routing to Cisco routers (or simulates the push), and updates both circuits' status in NetBox. **Step 2** (report) re-queries NetBox for current state, renders a timestamped HTML incident report with topology diagrams and audit trails, and publishes it to GitHub Pages.

The entire pipeline — from status change to published report — completes in under 30 seconds.

---

## Solution Walkthrough

### Use Case A: Event-Driven Circuit Failover

**The Scenario:** A global enterprise operates WAN circuits between three sites — Bristol (GB), Atlanta (US), and Buenos Aires (AR). The primary 10 Gbps circuit between GB and US fails. Automation must discover the 5 Gbps backup circuit, reconfigure routers at both sites, and update the CMDB — all without human intervention.

#### A1. Configure the EDA Rulebook

**Operational Impact:** None — rulebook configuration is read-only until activated.

The EDA rulebook listens for NetBox webhook events and triggers the failover workflow when a circuit goes offline or failed.

**EDA Rulebook (`rulebooks/rulebook.yml`):**

```yaml
---
- name: NetBox Circuit Failover
  hosts: all
  sources:
    - name: netbox_webhook
      ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000
  rules:
    - name: Circuit failure detected - trigger failover workflow
      condition: >-
        event.payload.object_type == "circuits.circuit" and
        event.payload.data.status.value in ["offline", "failed"]
      action:
        run_workflow_template:
          name: "SummitCollection Circuit Failover Workflow"
          organization: "SummitCollection"
          job_args:
            extra_vars:
              failed_circuit: "{{ event.payload.data.cid }}"
```

> **Tip:** The rulebook extracts the circuit ID (`cid`) from the NetBox event payload and passes it as `failed_circuit` to the workflow. This single variable drives all downstream logic — no hardcoded circuit mappings.

#### A2. Configure NetBox Webhook and Event Rule

**Operational Impact:** Low — creates a webhook and event rule in NetBox. Reversible by deleting both objects.

NetBox must be configured to fire a webhook when circuit status changes. The setup playbook handles this idempotently:

**Webhook and Event Rule Configuration (from `pb_setup_aap.yml`):**

```yaml
- name: Create NetBox webhook for EDA
  ansible.builtin.uri:
    url: "{{ netbox_url }}/api/extras/webhooks/"
    method: POST
    headers:
      Authorization: "Token {{ netbox_token }}"
    body_format: json
    body:
      name: "AAP Circuit Failover Workflow"
      payload_url: "https://{{ aap_host }}/api/controller/v2/workflow_job_templates/{{ wfjt_id }}/launch/"
      http_method: POST
      http_content_type: application/json
      additional_headers: "Authorization: Bearer {{ aap_token }}"
      ssl_verification: false

- name: Create NetBox event rule
  ansible.builtin.uri:
    url: "{{ netbox_url }}/api/extras/event-rules/"
    method: POST
    headers:
      Authorization: "Token {{ netbox_token }}"
    body_format: json
    body:
      name: "Circuit Failover on Status Change"
      enabled: true
      object_types: ["circuits.circuit"]
      event_types: ["object_updated"]
      action_type: webhook
      action_object_id: "{{ webhook_id }}"
```

> **Why use `object_updated` instead of a status-specific trigger?** NetBox event rules fire on object-level events, not field-level changes. The EDA rulebook condition handles the status filtering — this separation keeps NetBox configuration simple and moves decision logic to EDA where it belongs.

#### A3. Dynamic Backup Discovery

**Operational Impact:** None — this step is read-only, querying NetBox for available circuits.

The failover playbook discovers backup circuits dynamically. It extracts the A-side and Z-side sites from the failed circuit's terminations, then queries all circuits tagged `dd` that terminate at both sites. The best backup is selected by highest committed bandwidth.

**Backup Discovery Logic (from `pb_circuit_failover.yml`):**

```yaml
- name: Query all circuits tagged 'dd' at both sites
  ansible.builtin.set_fact:
    backup_candidates: >-
      {{ all_dd_circuits | selectattr('value.status.value', 'eq', 'active')
         | rejectattr('value.cid', 'eq', failed_circuit)
         | selectattr('value.terminations', 'defined')
         | list }}

- name: Select best backup by highest committed bandwidth
  ansible.builtin.set_fact:
    selected_backup: >-
      {{ backup_candidates
         | sort(attribute='value.commit_rate', reverse=true)
         | first }}
```

> **Why dynamic discovery instead of a backup mapping table?** Hardcoded primary-backup pairs break when circuits are added, removed, or re-provisioned. Dynamic discovery means adding a new circuit to NetBox with the `dd` tag automatically includes it as a failover candidate. The automation adapts to topology changes without playbook modifications.

#### A4. Router Configuration and CMDB Update

**Operational Impact:** High — pushes routing configuration to production routers and modifies circuit status in NetBox.

After selecting the backup circuit, the playbook derives per-router gateway IPs from NetBox cable wiring data and pushes failover routing. It then updates both circuits' status in NetBox.

**Per-Router Gateway Derivation:**

```yaml
- name: Derive gateway from NetBox cable wiring
  ansible.builtin.set_fact:
    router_gateways: >-
      {% set gw_map = {} %}
      {% for router in site_routers %}
      {%   set iface_ip = router.interfaces | map(attribute='ip_addresses')
                          | flatten | first %}
      {%   set gateway = iface_ip.address | ansible.utils.ipaddr('network/prefix')
                         | ansible.utils.nthhost(1) %}
      {%   set _ = gw_map.update({router.name: gateway}) %}
      {% endfor %}
      {{ gw_map }}
```

**Router Config Push and NetBox Update:**

```yaml
- name: Push failover routing to router
  cisco.ios.ios_config:
    lines:
      - "ip route 0.0.0.0 0.0.0.0 {{ backup_gateway }}"
      - "no ip route 0.0.0.0 0.0.0.0 {{ failed_gateway }}"

- name: Update circuit status in NetBox
  netbox.netbox.netbox_circuit:
    netbox_url: "{{ netbox_url }}"
    netbox_token: "{{ netbox_token }}"
    data:
      cid: "{{ selected_backup.value.cid }}"
      status: active
    state: present
```

> **Warning:** Router configuration changes take effect immediately. In production, consider adding a maintenance window check or approval gate before the `cisco.ios.ios_config` task. See [Maturity Path](#maturity-path) for the Walk stage with human approval.

---

### Use Case B: Automated Incident Reporting

**The Scenario:** After every circuit failover, stakeholders need a detailed incident report documenting what happened, which backup was selected and why, what router configuration was applied, and the timeline of automated actions. These reports must be immutable, timestamped, and accessible via a web URL.

#### B1. Report Generation from NetBox State

**Operational Impact:** None — reads current state from NetBox and renders a local HTML file.

Step 2 of the failover workflow re-queries NetBox for current circuit state and renders a Jinja2 HTML template with full incident details.

**Report Data Collection (from `pb_deploy_report.yml`):**

```yaml
- name: Query all circuits for report
  ansible.builtin.set_fact:
    report_circuits: >-
      {{ query('netbox.netbox.nb_lookup', 'circuits',
         api_endpoint=netbox_url,
         token=netbox_token,
         api_filter='tag=dd') }}

- name: Build per-router gateway lookup
  ansible.builtin.set_fact:
    router_gateway_map: "{{ dict(router_gw_pairs) }}"
```

The report template (`failover_report.html.j2`) includes:

- Network topology SVG diagram showing all three sites and circuits
- Failed and backup circuit details (CID, provider, bandwidth, port speed)
- Per-router gateway configuration table
- Bandwidth capacity impact analysis
- Backup candidate selection rationale with all candidates ranked
- Failover timeline with per-step timestamps
- Direct link to NetBox circuit history for audit trail

#### B2. Publishing to GitHub Pages

**Operational Impact:** Low — creates or updates files in the repository's `docs/` directory via the GitHub Contents API.

```yaml
- name: Publish report to GitHub Pages
  ansible.builtin.uri:
    url: >-
      https://api.github.com/repos/{{ github_repo }}/contents/docs/{{ report_filename }}
    method: PUT
    headers:
      Authorization: "Bearer {{ github_token }}"
    body_format: json
    body:
      message: "Update failover report"
      content: "{{ report_content | b64encode }}"
      sha: "{{ existing_file_sha | default(omit) }}"

- name: Generate and publish report index
  ansible.builtin.uri:
    url: >-
      https://api.github.com/repos/{{ github_repo }}/contents/docs/index.html
    method: PUT
    headers:
      Authorization: "Bearer {{ github_token }}"
    body_format: json
    body:
      message: "Update report index"
      content: "{{ index_content | b64encode }}"
      sha: "{{ index_sha | default(omit) }}"
```

> **Tip:** Each report gets a unique timestamped filename (`failover_report_<CID>_<ISO8601>.html`). An auto-generated index page lists all historical reports with newest first, creating a browsable incident history.

---

### Use Case C: Closed-Loop Failback

**The Scenario:** After the root cause of a primary circuit failure is resolved, the circuit is restored to active in NetBox. The automation should automatically deactivate the backup circuit and restore primary routing — completing the closed loop.

#### C1. Bidirectional Failover Logic

**Operational Impact:** Medium — same as Use Case A, but triggered by the backup circuit going offline.

The same EDA rulebook and failover playbook handle both directions. When the backup circuit is set to offline (because the primary is restored), the playbook discovers the primary as the "backup" candidate and restores it.

```
Primary fails → EDA triggers → Backup activated → Primary routing removed
Primary restored → Operator sets backup offline → EDA triggers → Primary re-activated → Backup routing removed
```

> **Warning:** Guard against event loops. The failover playbook updates circuit status in NetBox, which could trigger another webhook. The rulebook condition (`status in ["offline", "failed"]`) naturally prevents loops because the *activated* circuit's status change (to `active`) does not match the trigger condition.

---

## Validation

### Testing the End-to-End Pipeline

**Test method:** Trigger a circuit status change via the NetBox API and verify the complete pipeline executes.

**Step 1 — Trigger the failover via curl:**

```bash
curl -s -X PATCH \
  -H "Authorization: Token $NETBOX_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "offline"}' \
  "$NETBOX_URL/api/circuits/circuits/?cid=IPLC-GB-AT-PRI"
```

**Step 2 — Verify in AAP UI:**
Navigate to **Automation Execution > Jobs** and confirm the "Circuit Failover Workflow" job launched and completed successfully.

**Step 3 — Verify in NetBox:**
Navigate to **Circuits > Circuits** and confirm:
- `IPLC-GB-AT-PRI` status is `offline`
- `IPLC-GB-AT-SEC` status is `active`

**Step 4 — Verify the report:**
Open the GitHub Pages URL and confirm a new timestamped report appears in the index.

### Expected Results

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| NetBox Event | Webhook fired | Event rule shows recent activity in NetBox admin |
| EDA Rulebook | Condition matched | Rulebook activation fire count increments in AAP > Automation Decisions |
| Failover Job | Backup discovered and selected | Job output shows `selected_backup: IPLC-GB-AT-SEC` with commit_rate |
| Router Config | Routes pushed (or simulated) | Job output shows `ios_config` task or `[SIMULATED]` debug output |
| NetBox Update | Both circuits updated | Primary = offline, Backup = active in NetBox UI |
| Report Published | HTML report accessible | New report visible at GitHub Pages URL with correct timestamp |
| Report Content | All sections populated | Topology diagram, circuit details, gateway table, timeline present |

### Troubleshooting Common Failures

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| EDA rulebook does not fire | NetBox webhook URL incorrect or EDA port blocked | Verify webhook `payload_url` matches EDA endpoint. Check firewall rules for port 5000. Test with `curl -X POST http://<eda-host>:5000/endpoint -d '{}'` |
| Workflow launches but failover job fails with "No backup found" | No other `dd`-tagged circuits exist between the same sites, or all candidates are already offline | Verify circuits are tagged `dd` in NetBox. Check that at least one circuit between the same A-side and Z-side sites is in `active` status |
| NetBox API returns 403 Forbidden | Token lacks write permissions or token format incompatible | Use a NetBox v1 token (not v2) with full API permissions. For NetBox 4.5+, ensure pynetbox >= 7.6.0 in the EE |
| Router config push times out | SSH connectivity issue or crypto policy mismatch with older IOS-XE | For CSR 1000v 16.12 (SHA-1 only), use a legacy-crypto EE with override policies. For newer platforms, the standard EE works |
| Report not published to GitHub Pages | GitHub token missing `repo` scope or GitHub Pages not enabled | Verify `GITHUB_TOKEN` has `repo` scope. Enable GitHub Pages on the repository from Settings > Pages > Source: `main` branch, `/docs` folder |

---

## Maturity Path

| Maturity | Detection & Trigger | Failover Execution | Reporting & Audit | Example |
|----------|-------------------|-------------------|-------------------|---------|
| **Crawl** | Manual: operator updates NetBox circuit status via UI | Semi-automated: operator launches failover job template manually from AAP with circuit CID as survey input | Manual: operator runs report playbook after failover | Run `pb_circuit_failover.yml` as a standalone job template with `failed_circuit` as a survey variable. No EDA, no webhook. |
| **Walk** | Automated trigger: NetBox webhook fires to EDA on status change | Automated with approval: EDA triggers workflow but first step requires human approval in AAP before proceeding | Automated: report generated and published as workflow step 2 | Add an approval node between Step 1 (failover) and Step 2 (report) in the AAP workflow. EDA triggers automatically, but a human reviews before execution. |
| **Run** | Fully automated: NetBox event → EDA → AAP workflow, zero human touch | Fully automated: failover + failback both execute without intervention, with guard rails against loops | Fully automated: timestamped reports published, index maintained, audit trail linked | Full pipeline as described in this guide. Add monitoring integration (PagerDuty, Slack) for notification after automated failover completes. |

---

## Related Guides

- **[Event-Driven Network Configuration with NetBox and AAP](README-NetBox-EDA-Config-Solution-Guide.md)** — Foundational guide covering NetBox dynamic inventory, config contexts, and event-driven NTP/banner/VLAN configuration. Start here if your team is new to NetBox + EDA integration.

- **[EDA + NetBox Workshop](https://github.com/redhat-zt/zt-ans-bu-eda-netbox)** — 7-module hands-on workshop covering AAP dynamic inventory, EDA rulebooks, NetBox webhooks, and workflow automation. Ideal for teams new to Event-Driven Ansible.

- **[NetBox as a Dynamic Inventory Source](https://docs.ansible.com/ansible/latest/collections/netbox/netbox/nb_inventory_inventory.html)** — Documentation for the `netbox.netbox.nb_inventory` plugin used to dynamically pull device and site data from NetBox into Ansible inventories.

- **[Event-Driven Ansible Documentation](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/event-driven_ansible_controller_user_guide/index)** — Official Red Hat documentation for EDA controller configuration, rulebook syntax, and action plugins.

- **[NetBox Webhooks and Event Rules](https://netboxlabs.com/docs/netbox/en/stable/integrations/webhooks/)** — NetBox documentation for configuring webhooks and event rules that trigger external automation.

---

## Summary

This guide demonstrated three progressively mature use cases for automated WAN circuit failover:

- **Use Case A** established the event-driven pipeline: a circuit status change in NetBox triggers EDA, which launches an AAP workflow that dynamically discovers backup circuits, reconfigures routers, and updates the CMDB — all in under 30 seconds.

- **Use Case B** added automated incident reporting: every failover produces a timestamped HTML report with topology diagrams, bandwidth impact analysis, backup selection rationale, and NetBox audit trail links, published automatically to GitHub Pages.

- **Use Case C** closed the loop with automated failback: the same pipeline handles both directions, restoring primary routing when the failed circuit is brought back online.

The unifying pattern across all three use cases is **NetBox as the single source of truth driving event-based automation**. By modeling circuits, sites, devices, and their interconnections in NetBox, the automation adapts dynamically to topology changes — no hardcoded mappings, no manual CMDB updates, no missed routers.

---

## Next Steps

- **[Try Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible/trial)** — Start a free trial of AAP including Event-Driven Ansible
- **[Red Hat Consulting](https://www.redhat.com/en/services/consulting)** — Engage Red Hat consultants for production NetBox + AAP architecture
- **[Red Hat Training](https://www.redhat.com/en/services/training-and-certification)** — Ansible automation training and certification paths

---

## Sources

- [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)
- [NetBox Documentation](https://netboxlabs.com/docs/netbox/en/stable/)
- [netbox.netbox Ansible Collection](https://galaxy.ansible.com/ui/repo/published/netbox/netbox/)
- [Event-Driven Ansible](https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible)
- [Summit Demo Source Code](https://github.com/leogallego/summit-netbox-circuits-demo)
