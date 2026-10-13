# Vibe pre_tool hook: blocks E&P Knowledge Base tools until the dora-assessment skill is
# loaded in the session. Vibe picks skills from their description alone and does not pass
# the server's own instructions to the model, so without this gate a model can call the
# Knowledge Base directly and skip the skill's scope and evidence gates.
#
# Input: Vibe's hook JSON on stdin. Output: {"decision": "allow" | "deny", "reason": ...}.
$ErrorActionPreference = 'Stop'

$inv      = [Console]::In.ReadToEnd() | ConvertFrom-Json
$markerDir = Join-Path ([IO.Path]::GetTempPath()) 'vibe-dora-gate'
$marker    = Join-Path $markerDir ($inv.session_id -replace '[^A-Za-z0-9_-]', '_')

function Respond($decision, $reason) {
    $out = @{ decision = $decision }
    if ($reason) { $out.reason = $reason }
    $out | ConvertTo-Json -Compress
    exit 0
}

# The skill is being loaded: remember it for this session.
if ($inv.tool_name -eq 'skill') {
    if ($inv.tool_input.name -eq 'dora-assessment') {
        New-Item -ItemType Directory -Force $markerDir | Out-Null
        New-Item -ItemType File -Force $marker | Out-Null
    }
    Respond 'allow'
}

# A Knowledge Base tool: allow only once the skill is loaded. A skill the user invoked with
# /dora-assessment may not pass through this hook, so the transcript is checked as well.
$loaded = Test-Path $marker
if (-not $loaded -and $inv.transcript_path -and (Test-Path $inv.transcript_path)) {
    $loaded = [bool](Select-String -Path $inv.transcript_path -SimpleMatch -Quiet `
        -Pattern 'skill_content name=\"dora-assessment\"', 'skill_content name="dora-assessment"')
}
if ($loaded) { Respond 'allow' }

Respond 'deny' ('The dora-assessment skill must be loaded before any E&P Knowledge Base ' +
    'tool is used. Call the skill tool with name "dora-assessment" now, then follow its ' +
    'instructions from the start, including its scope and evidence gates.')
