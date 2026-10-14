# DORA Assessment Plugin

Assesses DORA (Digital Operational Resilience Act) compliance evidence across all
five pillars — ICT risk management, incident reporting, resilience testing and TLPT,
the Register of Information and ICT third-party risk, and information sharing — by
cross-checking the
E&P Knowledge Base against **your own** ServiceNow data. Acts as an assessment agent —
it reports what can and can't be evidenced, and helps build missing
structures. It does not perform resilience testing, author policy, or attest
compliance.

Using it requires an E&P Knowledge Base account. The plugin on its own holds the
assessment method, not the criteria; without an access key it cannot answer.

## What you need to bring

**This plugin does not contain your data, and E&P cannot reach into your
systems.** The Knowledge Base holds the criteria: for each pillar it covers, the
regulation in plain language, the report or register templates field by field,
how it is built in ServiceNow, and the checks an assessment runs. What is
actually true in your environment has to come from you, in your own session.

The library currently covers **all five pillars**. The skill reads the scope
from the library itself (`list_documents`), so a pillar E&P adds later is picked
up without a plugin update. Questions about the oversight of critical ICT providers
(Articles 31–44) are answered as `out of scope`, not from general knowledge.

Supply one of these, for the pillar you are asking about:

| Pillar | ServiceNow connector (mode A) | Export (mode B) | Description (mode C) |
|---|---|---|---|
| **1 — ICT risk** | The CMDB/CSDM: functions, CIs, information assets. Every check. | A CMDB or asset-inventory export. Check 5 (the evidence chain) only with a relationship table. | Orientation only. |
| **2 — incidents** | Incident, Security Incident Response, Digital Resilience Incident Reporting and the CMDB. Every check. | Incidents with their DRI assessments, or the submitted reports (Excel/Word). Not incidents that were never reported. | Orientation only. |
| **3 — testing** | Operational Resilience Management (scenario analysis) plus tester and programme records. Every check. | Test/scenario records and tester details. TLPT scope only with CI or relationship data. | Orientation only. |
| **4 — register** | The DORA register tables. Every check. | B1: the Register of Information (Excel master template or CSV package). B2: the CMDB and its relationships. | Orientation only. |
| **5 — info sharing** | The compliance records where memberships are tracked. | A list of arrangements with join, leave and notification dates. | Whether a notification process exists. |

Your assistant reads your data where it already lives and consults the
Knowledge Base separately. **Your data is never sent to E&P.**

**If you supply none of these, the skill stops and asks for one.** That
applies to every in-scope question, including general ones like "what
does Article 30 require?". The service answers questions about *your* setup,
measured against the library, not questions in the abstract.

## Install

Every route installs the same skill and the same Knowledge Base connector. Release
downloads are on this repo's [Releases](../../releases) page; use the files named below,
not GitHub's "Source code" archives.

| You use | Install |
|---|---|
| **Claude Code** | `/plugin marketplace add Einar-Partners/dora-assessment`, then `/plugin install dora-assessment@einar-partners-marketplace` |
| **Claude Desktop / claude.ai** | Download `dora-plugin-<version>-claude.zip`, then Plugins → Upload local plugin (on Team and Enterprise plans, an admin may do this for the organisation).<br><br>Alternatively, go to Plugins & skills → Sync from GitHub and enter the URL of this repo: `https://github.com/Einar-Partners/dora-assessment`. With this method, your plugin version stays up to date. |
| **ChatGPT** | A workspace admin uploads `dora-assessment-<version>-chatgpt.zip`; see [chatgpt/README.md](chatgpt/README.md) |
| **Mistral Vibe** (CLI or web) | See [vibe/README.md](vibe/README.md) |

**Updates.** In Claude Code, marketplaces other than Anthropic's own do not update
automatically by default. Turn on auto-update for this marketplace in `/plugin`, or run
`/plugin marketplace update einar-partners-marketplace`. In Claude Desktop / claude.ai,
a plugin added with Sync from GitHub stays up to date on its own. Zip installs are
updated by uploading the zip of the new release. What changed in each version is in
[CHANGELOG.md](CHANGELOG.md).

## Sign in

The plugin declares one connector in `plugin/.mcp.json`: `dora-knowledge-base`, the E&P
Knowledge Base MCP.

**Installing the plugin declares that server. It does not sign you in.** The
first time the skill uses it, your client starts an authorisation flow and
asks for your access key — paste the `ecl_…` key E&P sent you when your
account was provisioned. Programmatic clients can send it as an
`Authorization: Bearer ecl_…` header instead and skip the browser step. See
`plugin/skills/dora-assessment/CONNECTORS.md` for both routes.

Treat the key like a password. If it is lost or exposed, see [SECURITY.md](SECURITY.md).

If you have a ServiceNow MCP connector, add it to **your own** client
configuration. The skill uses it when present and falls back to modes B and C
when it isn't.

## Usage

Trigger by asking about major-incident classification, reporting deadlines,
incident report fields, the Register of Information, RoI templates or columns,
ICT third-party providers, contracts, concentration risk, or threat-intelligence
sharing — or by asking things like "are we compliant with X" / "assess us
against DORA". The skill auto-triggers; no slash command
needed.

## Components

- **Skill**: `plugin/skills/dora-assessment/SKILL.md` — the shared core: scope and
  evidence gates, routing logic, assessment states, severity model, and output
  contract.
- **Pillar references**: `plugin/skills/dora-assessment/references/pillar-N.md` — per
  pillar, the evidence modes, the documents to load and the mechanics its checks
  need. Loaded only for the pillar a question touches.

## Support and licence

Questions and support: [ping@einar.partners](mailto:ping@einar.partners). Security issues
and leaked keys: see [SECURITY.md](SECURITY.md).

The output is advisory. It is not legal advice and not a regulatory attestation or
certification.

This plugin is proprietary software of Einar & Partners, licensed under the terms in
[LICENSE](LICENSE). It is published so that licensees can install it; publication grants
no other rights. Maintainers: see [MAINTAINING.md](MAINTAINING.md).
