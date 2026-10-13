# Maintaining this repo

This repo is public. Everything in it, including every commit, PR, issue and CI log, can
be read by anyone. Read "Working in public" before your first change.

## Layout

| Path | What it is | Reaches clients via |
|---|---|---|
| `.claude-plugin/marketplace.json` | Makes the repo a Claude marketplace; its one entry points at `./plugin` | Claude Code marketplace |
| `plugin/` | The Claude plugin: manifest, `.mcp.json`, the skill. A marketplace install copies exactly this folder | Marketplace, Claude zip |
| `chatgpt/` | ChatGPT wrapper: its own manifest, connector and `SKILL.md`; shares `plugin/.../references/` | ChatGPT zip |
| `vibe/` | Mistral Vibe installers, gate hook and connector snippet | Vibe zips |
| `scripts/package.ps1` | Builds the four client zips from an allowlist | — |
| `.github/` | CI checks, release workflows, release-notes header | — |

## Shipping a version

**Shipping = raising `version` in `plugin/.claude-plugin/plugin.json`** (and in
`chatgpt/plugin.json`, which must match) in a PR, and merging it.

- The merge ships to Claude Code marketplace installs straight away.
- `.github/workflows/auto-release.yml` then tags `v<version>`, builds the four zips and
  publishes a GitHub Release with them attached. The release notes are
  `.github/release-notes.md` followed by GitHub's list of merged PRs.
- A merge without a version bump ships nothing, to either route.
- Add the client-visible changes to [CHANGELOG.md](CHANGELOG.md) in the same PR.

The PR review is the release decision. If the release run fails, fix the cause and re-run
the workflow from the Actions tab (Run workflow). An unfinished draft from the failed run
is replaced; a published release is never touched.

**Dry run.** Publish a pre-release tagged `v<version>-test`; `release-packages.yml` builds
and attaches the zips. Delete the release and then its tag afterwards.

## Building locally

```powershell
pwsh scripts/package.ps1
```

This writes four files to `dist/` (not committed), named with the version from
`plugin/.claude-plugin/plugin.json`:

| File | For | Client installs it by |
|---|---|---|
| `dora-plugin-<version>-claude.zip` | Claude | Plugins → Upload local plugin |
| `dora-assessment-<version>-mistral-web.zip` | Vibe web app | Unzipping, then Context → Skills → Upload skill folder |
| `dora-assessment-<version>-mistral-cli.zip` | Vibe CLI | Unzipping, then running `vibe\install.ps1` |
| `dora-assessment-<version>-chatgpt.zip` | ChatGPT | A workspace admin: Admin → Plugins → Add → Upload plugin |

The script packages an allowlist of files only, so `.github/`, `scripts/` and anything
added to the repo later never ship in a zip. It stops without writing anything if:

- `marketplace.json` carries its own version (it must not: the version lives in
  `plugin/.claude-plugin/plugin.json` only) or does not point at `./plugin`;
- the skill description is over 500 characters or would break the YAML header;
- a packaged file contains a forbidden string: a SharePoint URL, an internal endpoint or
  an `ecl_` key;
- the Knowledge Base URL differs between the files that carry it;
- the ChatGPT manifest disagrees with the Claude one.

## CI

On every PR and every push to the default branch:

- **Connector URL check** (`connector-url-check.yml`): no internal or tenant URL and no
  email address other than `ping@einar.partners` anywhere in the repo; `plugin/` holds
  only the allowed files; the shipped connector configs declare the Knowledge Base and
  nothing else; the skill frontmatter parses; the zips build.
- **Secret scan** (`secret-scan.yml`): gitleaks over the full history, with an extra rule
  for `ecl_` access keys (`.gitleaks.toml`).

## If the Knowledge Base host moves

Change these together, in one PR with a version bump: `plugin/.mcp.json`,
`plugin/skills/dora-assessment/CONNECTORS.md`, `chatgpt/mcp.json`,
`chatgpt/skills/dora-assessment/CONNECTORS.md`, `vibe/config.snippet.toml`, and the URL
pattern in `scripts/package.ps1`. Every client has to sign in again afterwards.

## Working in public

- **No client names, tenant details or client data** in commits, PRs, issues or CI logs.
- **No internal URLs or E&P-internal connector details.** Those live in E&P's private
  documentation. CI fails on the patterns it knows, but it cannot know them all.
- **Commit with a GitHub `noreply` address or `ping@einar.partners`.** In GitHub →
  Settings → Emails, turn on *Keep my email addresses private* and *Block command line
  pushes that expose my email*. CI rejects other addresses in files, not in commit
  metadata.
- **Never commit a key.** If it happens anyway, have the key revoked at once. Rewriting
  history does not help once a commit is public.
- **CI is the second line of defence, not the first.** It only runs after a push.
