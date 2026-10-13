# DORA Assessment for Mistral Vibe

The same skill as the Claude plugin, packaged for the [Mistral Vibe CLI](https://github.com/mistralai/mistral-vibe).
Vibe has no plugin or marketplace system, so instead of a one-click install this folder
ships an install script and a config snippet. The skill itself is not duplicated: the
script copies `plugin/skills/dora-assessment/` from the repo, so both distributions always
run the same version.

| Claude plugin | Vibe |
|---|---|
| `plugin/skills/dora-assessment/` | Copied to `~/.vibe/skills/dora-assessment/` |
| `plugin/.mcp.json` → `dora-knowledge-base` | `config.snippet.toml`, appended to `~/.vibe/config.toml` |
| `plugin/.claude-plugin/plugin.json`, marketplace | `install.ps1` / `install.sh` |

Everything in the main [README](../README.md) about scope, evidence and your data applies
unchanged.

Download `dora-assessment-<version>-mistral-cli.zip` (CLI) or `-mistral-web.zip` (web
app) from this repo's Releases page, or clone the repo. The steps below work the same from
an unzipped package as from a checkout.

## Install

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File vibe\install.ps1
```

macOS / Linux:

```bash
bash vibe/install.sh
```

Then add the `ecl_…` access key E&P sent you to `~/.vibe/.env`:

```
EP_KNOWLEDGE_KEY=ecl_…
```

Vibe sends it as `Authorization: Bearer ecl_…`, the programmatic route described in
[CONNECTORS.md](../plugin/skills/dora-assessment/CONNECTORS.md). There is no browser sign-in step.

To update, pull the repo (or unzip the new `mistral-cli` package) and run the script again.
It replaces the skill, and if the Knowledge Base has moved it also points your existing
`knowledge_base` entry at the new URL, changing nothing else in `config.toml`. The script
prints `Connector updated: <old> -> <new>` when it does. Before that fix, re-running left an
old URL in place: after the 2026-10-12 move to `uplink.einar.partners`, an install from
before then answers 404 until the script is run once more.

## The gate hook

The installer also registers a `pre_tool` hook in `~/.vibe/hooks.toml`
([dora_gate.ps1](hooks/dora_gate.ps1) / [dora_gate.sh](hooks/dora_gate.sh)). It blocks
every Knowledge Base tool call until the `dora-assessment` skill has been loaded in the
session, and tells the model to load it.

It exists because Vibe decides whether to load a skill from its description alone, and
does not pass the Knowledge Base server's own instructions to the model. In testing,
Mistral Medium answered "What does Article 30 require?" by calling the Knowledge Base
directly, skipping the skill's scope and evidence gates, even with a description that
told it to load the skill first. Claude needs no equivalent.

## Vibe web app

The web app takes the same skill folder: `Context` → `Skills` → `Import` → `Upload skill
folder`, and pick `plugin/skills/dora-assessment` (in an unzipped `mistral-web` package: the `dora-assessment` folder). Add the Knowledge Base under `Connectors` →
`+ Add Connector` → `Custom MCP Connector`, with the URL from `config.snippet.toml`; the
sign-in page asks for the `ecl_…` key.

Two differences from the CLI:

- **Descriptions are capped at 500 characters.** The skill's description is kept under
  that cap, so the folder uploads as it is. Keep it there when editing `SKILL.md`.
- **There are no hooks, so there is no gate.** In testing the skill still triggered on
  its own. If it does not, start the question with `/dora-assessment`.

## Tool names

Vibe prefixes MCP tools with the server name, so the skill's `list_documents` and
`get_document` appear as `knowledge_base_list_documents` and
`knowledge_base_get_document`. They are the same tools.

## Your ServiceNow

As with the Claude plugin, a ServiceNow MCP connector is yours to add, as another
`[[mcp_servers]]` entry in your own `~/.vibe/config.toml`. The skill uses it when present.
