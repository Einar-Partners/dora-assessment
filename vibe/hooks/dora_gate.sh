#!/usr/bin/env sh
# Vibe pre_tool hook: blocks E&P Knowledge Base tools until the dora-assessment skill is
# loaded in the session. Vibe picks skills from their description alone and does not pass
# the server's own instructions to the model, so without this gate a model can call the
# Knowledge Base directly and skip the skill's scope and evidence gates.
#
# Input: Vibe's hook JSON on stdin. Output: {"decision": "allow" | "deny", "reason": ...}.
inv=$(cat)

field() { printf '%s' "$inv" | sed -n "s/.*\"$1\": *\"\([^\"]*\)\".*/\1/p" | head -n 1; }

tool=$(field tool_name)
session=$(field session_id | tr -c 'A-Za-z0-9_-' '_')
transcript=$(field transcript_path)
marker_dir="${TMPDIR:-/tmp}/vibe-dora-gate"
marker="$marker_dir/$session"

allow() { printf '{"decision":"allow"}\n'; exit 0; }

# The skill is being loaded: remember it for this session.
if [ "$tool" = "skill" ]; then
  if printf '%s' "$inv" | grep -Eq '"tool_input": *\{[^}]*"name": *"dora-assessment"'; then
    mkdir -p "$marker_dir" && touch "$marker"
  fi
  allow
fi

# A Knowledge Base tool: allow only once the skill is loaded. A skill the user invoked with
# /dora-assessment may not pass through this hook, so the transcript is checked as well.
[ -f "$marker" ] && allow
if [ -n "$transcript" ] && [ -f "$transcript" ] &&
   grep -Eq 'skill_content name=\\?"dora-assessment\\?"' "$transcript"; then
  allow
fi

printf '%s\n' '{"decision":"deny","reason":"The dora-assessment skill must be loaded before any E&P Knowledge Base tool is used. Call the skill tool with name \"dora-assessment\" now, then follow its instructions from the start, including its scope and evidence gates."}'
