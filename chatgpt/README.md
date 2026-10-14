# DORA Assessment for ChatGPT

The same skill as the Claude plugin, packaged as a ChatGPT plugin. The assessment logic
is unchanged: the five pillar references in `plugin/skills/dora-assessment/references/` are
shared, not copied, so the checks cannot diverge between the two.

| Claude plugin | ChatGPT plugin |
|---|---|
| `plugin/.claude-plugin/plugin.json` | `chatgpt/plugin.json` (listing fields under `extensions.com.openai`) |
| `plugin/.mcp.json` (`"type": "http"`) | `chatgpt/mcp.json` (`"type": "streamable-http"`) |
| `plugin/skills/dora-assessment/SKILL.md` | `chatgpt/skills/dora-assessment/SKILL.md` |
| `plugin/skills/dora-assessment/CONNECTORS.md` | `chatgpt/skills/dora-assessment/CONNECTORS.md` |
| `plugin/skills/dora-assessment/references/` | the same folder, packaged as is |

The connector is called `dora-knowledge-base`, as in Claude, and points at
`https://uplink.einar.partners/dora/mcp`.

## What differs from the Claude plugin

- **No SharePoint.** The ChatGPT `SKILL.md` has no SharePoint, Microsoft 365 or SAP step.
  The Claude skill already treats that step as not applicable when no library is configured,
  so behaviour is the same; the ChatGPT package just does not mention it. Where evidence
  would have come from there, the skill reports it as `not determinable`.
- **Sign-in is OAuth only.** ChatGPT does not accept API keys or custom bearer headers, so
  the `Authorization: Bearer ecl_…` route is not offered. The browser sign-in asks for the
  `ecl_…` key, as it does in Claude.
- **Not connected.** If a user calls the skill before the Knowledge Base is connected, it
  stops and tells them to connect `dora-knowledge-base` at
  `https://uplink.einar.partners/dora/mcp`. A workspace admin enables the plugin first;
  then each user authorises the connector with their own `ecl_…` key. No key? Don't email
  us: request one at https://mcp.einar.partners.
- **Tool names.** ChatGPT may prefix the Knowledge Base tools with the server name. The
  ChatGPT `SKILL.md` says so.
- **No gate hook.** Plugins with lifecycle hooks cannot be submitted to ChatGPT, and the
  Vibe hook is not needed: this skill's `description` and the server's own instructions
  carry the gates.

## Keeping the two skills in step

`chatgpt/skills/dora-assessment/SKILL.md` is a copy of `plugin/skills/dora-assessment/SKILL.md`
with these changes only: Routing step 6 (SharePoint) removed and the next step renumbered,
Sources item 3 removed, the Tool map SharePoint line removed, one example in the check
classes reworded, and one tool-name sentence added. `chatgpt/skills/dora-assessment/CONNECTORS.md`
is the Claude one without the header-key route and the SharePoint section.

When you change the shared skill or its `CONNECTORS.md`, make the same change here.
`scripts/package.ps1` refuses to build if the two frontmatter blocks (name and
description) differ, if the plugin versions differ, or if the Knowledge Base URL differs
between the files that carry it. Bump `chatgpt/plugin.json` whenever
`plugin/.claude-plugin/plugin.json` changes.

## Building

```powershell
pwsh scripts/package.ps1
```

writes `dist/dora-assessment-<version>-chatgpt.zip`, with `plugin.json` and `mcp.json` at
the root and the skill under `skills/dora-assessment/`. The build stops if the plugin
version differs from the Claude one, if the listing fields exceed OpenAI's limits, if the
Knowledge Base URL differs from the other connector files, or if the package contains a
SharePoint/M365/SAP reference, an internal endpoint, an `ecl_` key, or review credentials.

## Installing

ChatGPT installs plugins from a ZIP. It does not install from a GitHub link.

- **Workspace admin:** Admin → Plugins → Add → Upload plugin, then choose the ZIP. New
  versions use "Upload new version". On Enterprise and Edu, plugins are off by default and
  an admin enables them first. Menu names change; check your own Admin console.
- **Public directory:** upload the ZIP in the OpenAI Platform dashboard. This needs
  `websiteURL`, `supportURL`, `privacyPolicyURL` and `termsOfServiceURL`, test cases, a demo
  recording and a reviewer test account, none of which are in this package yet.

Installing does not sign anyone in. Each user authorises the Knowledge Base on first use
with their own `ecl_…` key, sent separately. After upgrading from a package built before
5.2.2, sign in again: the old sign-in belonged to the Knowledge Base's previous address,
which no longer answers.

## If the Knowledge Base host moves again

The Vibe installers rewrite an existing connector's URL when they are re-run, so a Mistral
user only has to run the script again. ChatGPT has no installer. Rebuild the zip with the
new URL (the files named in "Keeping the two skills in step", plus `chatgpt/mcp.json`),
upload it as a new version, and have each user sign in again.

## Not yet verified

This package has not been uploaded to ChatGPT in this form. Still to confirm there:

- that the workspace upload accepts the package, and the `category` value in `plugin.json`;
- that sign-in completes against the new host. The Knowledge Base has seen sign-ins from
  `chatgpt.com` connectors, which is encouraging, but the server advertises
  `https://uplink.einar.partners/dora` as its resource while the connector URL ends in
  `/mcp`, and ChatGPT checks the token audience against the resource it sends;
- that the skill triggers on its description and the two gates hold, as in Claude.
