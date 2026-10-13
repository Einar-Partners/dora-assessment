# Installs the DORA Assessment skill and the E&P Knowledge Base connector into Mistral Vibe.
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File vibe\install.ps1
# Re-running updates the skill in place, and moves an existing connector entry to the current
# Knowledge Base URL. Nothing else in config.toml is touched.
$ErrorActionPreference = 'Stop'

$repo      = Split-Path -Parent $PSScriptRoot
$vibeHome  = if ($env:VIBE_HOME) { $env:VIBE_HOME } else { Join-Path $HOME '.vibe' }
$skillSrc  = Join-Path $repo 'plugin\skills\dora-assessment'
$skillDest = Join-Path $vibeHome 'skills\dora-assessment'
$config    = Join-Path $vibeHome 'config.toml'
$snippet   = Join-Path $PSScriptRoot 'config.snippet.toml'

# 1. Skill: replace any previous copy so removed reference files don't linger.
New-Item -ItemType Directory -Force (Split-Path $skillDest) | Out-Null
if (Test-Path $skillDest) { Remove-Item -Recurse -Force $skillDest }
Copy-Item -Recurse $skillSrc $skillDest
Write-Host "Skill installed:     $skillDest"

# 2. Connector: append the snippet once.
if (-not (Test-Path $config)) { New-Item -ItemType File $config | Out-Null }
if (Select-String -Path $config -Pattern 'name\s*=\s*"knowledge_base"' -Quiet) {
    # The entry exists, possibly from an older install that points at a host that has since
    # moved. Rewrite only the url line of the knowledge_base block.
    $newUrl = [regex]::Match((Get-Content -Raw $snippet), '(?m)^\s*url\s*=\s*"([^"]+)"').Groups[1].Value
    $text   = [IO.File]::ReadAllText($config)
    $eol    = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    $lines  = $text -split '\r?\n'
    $oldUrl = $null
    $i = 0
    while ($i -lt $lines.Count) {
        if ($lines[$i] -match '^\s*\[\[mcp_servers\]\]') {
            $end = $i + 1
            while ($end -lt $lines.Count -and -not ($lines[$end] -match '^\s*\[' -and $lines[$end] -notmatch '^\s*\[mcp_servers\.')) { $end++ }
            $block = $i..($end - 1)
            if ($block | Where-Object { $lines[$_] -match 'name\s*=\s*"knowledge_base"' }) {
                foreach ($k in $block) {
                    if ($lines[$k] -match '^\s*url\s*=\s*"([^"]*)"') {
                        $oldUrl = $Matches[1]
                        $lines[$k] = "url = `"$newUrl`""
                    }
                }
            }
            $i = $end
        } else { $i++ }
    }
    if ($oldUrl -and $oldUrl -ne $newUrl) {
        [IO.File]::WriteAllText($config, ($lines -join $eol), (New-Object Text.UTF8Encoding($false)))
        Write-Host "Connector updated:   $config ($oldUrl -> $newUrl)"
    } else {
        Write-Host "Connector present:   $config (already on $newUrl)"
    }
} else {
    Add-Content -Path $config -Value (Get-Content -Raw $snippet)
    Write-Host "Connector added:     $config"
}

# 3. Gate hook: blocks Knowledge Base tools until the skill is loaded (see hooks/dora_gate.ps1).
$hookDest  = Join-Path $vibeHome 'hooks\dora_gate.ps1'
$hooksToml = Join-Path $vibeHome 'hooks.toml'
New-Item -ItemType Directory -Force (Split-Path $hookDest) | Out-Null
Copy-Item -Force (Join-Path $PSScriptRoot 'hooks\dora_gate.ps1') $hookDest
if (-not (Test-Path $hooksToml)) { New-Item -ItemType File $hooksToml | Out-Null }
if (Select-String -Path $hooksToml -Pattern 'name\s*=\s*"dora-assessment-gate"' -Quiet) {
    Write-Host "Gate hook present:   $hooksToml (left unchanged)"
} else {
    Add-Content -Path $hooksToml -Value @"

[[hooks]]
name = "dora-assessment-gate"
type = "pre_tool"
match = 're:^(skill|knowledge_base_.*)$'
command = 'powershell -NoProfile -ExecutionPolicy Bypass -File "$hookDest"'
timeout = 20
"@
    Write-Host "Gate hook added:     $hooksToml"
}

# 4. Access key.
$envFile = Join-Path $vibeHome '.env'
$hasKey  = $env:EP_KNOWLEDGE_KEY -or ((Test-Path $envFile) -and (Select-String -Path $envFile -Pattern '^EP_KNOWLEDGE_KEY=' -Quiet))
if (-not $hasKey) {
    Write-Host ""
    Write-Host "Next: add your E&P access key to $envFile :"
    Write-Host "  EP_KNOWLEDGE_KEY=ecl_..."
}
