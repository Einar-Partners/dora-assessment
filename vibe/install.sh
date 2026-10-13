#!/usr/bin/env bash
# Installs the DORA Assessment skill and the E&P Knowledge Base connector into Mistral Vibe.
# Run from anywhere:  bash vibe/install.sh
# Re-running updates the skill in place, and moves an existing connector entry to the current
# Knowledge Base URL. Nothing else in config.toml is touched.
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"
repo="$(dirname "$here")"
vibe_home="${VIBE_HOME:-$HOME/.vibe}"
skill_dest="$vibe_home/skills/dora-assessment"
config="$vibe_home/config.toml"

# 1. Skill: replace any previous copy so removed reference files don't linger.
mkdir -p "$vibe_home/skills"
rm -rf "$skill_dest"
cp -R "$repo/plugin/skills/dora-assessment" "$skill_dest"
echo "Skill installed:     $skill_dest"

# 2. Connector: append the snippet once.
touch "$config"
if grep -qE 'name[[:space:]]*=[[:space:]]*"knowledge_base"' "$config"; then
  # The entry exists, possibly from an older install that points at a host that has since
  # moved. Rewrite only the url line of the knowledge_base block.
  new_url=$(sed -n 's/^[[:space:]]*url[[:space:]]*=[[:space:]]*"\([^"]*\)".*/\1/p' "$here/config.snippet.toml" | head -n 1)
  awk -v new="$new_url" '
    { line[NR] = $0 }
    END {
      n = NR; i = 1
      while (i <= n) {
        if (line[i] ~ /^[[:space:]]*\[\[mcp_servers\]\]/) {
          s = i; e = i + 1
          while (e <= n && !(line[e] ~ /^[[:space:]]*\[/ && line[e] !~ /^[[:space:]]*\[mcp_servers\./)) e++
          kb = 0
          for (k = s; k < e; k++) if (line[k] ~ /name[[:space:]]*=[[:space:]]*"knowledge_base"/) kb = 1
          if (kb) for (k = s; k < e; k++) if (line[k] ~ /^[[:space:]]*url[[:space:]]*=/) {
            cr = (line[k] ~ /\r$/) ? "\r" : ""
            if (match(line[k], /"[^"]*"/)) old = substr(line[k], RSTART + 1, RLENGTH - 2)
            line[k] = "url = \"" new "\"" cr
          }
          i = e
        } else i++
      }
      for (k = 1; k <= n; k++) print line[k]
      print old > "/dev/stderr"
    }' "$config" > "$config.tmp" 2> "$config.old"
  old_url=$(tr -d '\r\n' < "$config.old"); rm -f "$config.old"
  if [ -n "$old_url" ] && [ "$old_url" != "$new_url" ]; then
    mv "$config.tmp" "$config"
    echo "Connector updated:   $config ($old_url -> $new_url)"
  else
    rm -f "$config.tmp"
    echo "Connector present:   $config (already on $new_url)"
  fi
else
  cat "$here/config.snippet.toml" >> "$config"
  echo "Connector added:     $config"
fi

# 3. Gate hook: blocks Knowledge Base tools until the skill is loaded (see hooks/dora_gate.sh).
hook_dest="$vibe_home/hooks/dora_gate.sh"
hooks_toml="$vibe_home/hooks.toml"
mkdir -p "$vibe_home/hooks"
cp "$here/hooks/dora_gate.sh" "$hook_dest"
chmod +x "$hook_dest"
touch "$hooks_toml"
if grep -qE 'name[[:space:]]*=[[:space:]]*"dora-assessment-gate"' "$hooks_toml"; then
  echo "Gate hook present:   $hooks_toml (left unchanged)"
else
  cat >> "$hooks_toml" <<EOF

[[hooks]]
name = "dora-assessment-gate"
type = "pre_tool"
match = 're:^(skill|knowledge_base_.*)\$'
command = 'sh "$hook_dest"'
timeout = 20
EOF
  echo "Gate hook added:     $hooks_toml"
fi

# 4. Access key.
env_file="$vibe_home/.env"
if [ -z "${EP_KNOWLEDGE_KEY:-}" ] && ! grep -qs '^EP_KNOWLEDGE_KEY=' "$env_file"; then
  echo
  echo "Next: add your E&P access key to $env_file :"
  echo "  EP_KNOWLEDGE_KEY=ecl_..."
fi
