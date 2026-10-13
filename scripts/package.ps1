# Builds the client packages for one release into dist/:
#   dora-plugin-<version>-claude.zip           Claude: Plugins -> Upload local plugin
#   dora-assessment-<version>-mistral-web.zip  Vibe web: unzip, then Upload skill folder
#   dora-assessment-<version>-mistral-cli.zip  Vibe CLI: unzip, then run vibe\install.ps1
#   dora-assessment-<version>-chatgpt.zip      ChatGPT: workspace admin uploads the ZIP
#
# Only the files listed below are packaged. .github/, scripts/ and anything else in the repo
# never reach a client, whatever is added to the repo later.
#
# Usage:  pwsh scripts/package.ps1
#
# Publishing a GitHub Release runs this same script (.github/workflows/release-packages.yml)
# and attaches the zips to the release.
$ErrorActionPreference = 'Stop'

$repo  = Split-Path -Parent $PSScriptRoot
$plugin = 'plugin'                         # the marketplace source: all a Claude install copies
$skill  = "$plugin/skills/dora-assessment"
$dist   = Join-Path $repo 'dist'

function Fail($message) { Write-Host "ERROR: $message" -ForegroundColor Red; exit 1 }

# --- Checks -----------------------------------------------------------------------------

# Version: plugin.json is the only source. Claude takes plugin.json over the marketplace
# entry without warning, so the entry must not carry a version of its own, and it must point
# at the plugin folder rather than the repo root.
$version = (Get-Content -Raw (Join-Path $repo "$plugin/.claude-plugin/plugin.json") | ConvertFrom-Json).version
$entry   = (Get-Content -Raw (Join-Path $repo '.claude-plugin/marketplace.json') | ConvertFrom-Json).plugins[0]
if (-not $version) { Fail "No version in $plugin/.claude-plugin/plugin.json." }
if ($entry.PSObject.Properties.Name -contains 'version') { Fail 'marketplace.json carries a version; set it in plugin.json only.' }
if ($entry.source -ne "./$plugin") { Fail "marketplace.json source is '$($entry.source)'; it must be './$plugin'." }

# Skill frontmatter. CI parses it as YAML; this catches the two mistakes that have broken the
# upload before: a description over the Vibe web app's 500 characters, and a ": " that turns
# the description line into invalid YAML.
$lines = Get-Content (Join-Path $repo "$skill/SKILL.md") -Encoding utf8
if ($lines[0] -ne '---') { Fail 'SKILL.md does not start with a --- frontmatter block.' }
$end = [Array]::IndexOf($lines, '---', 1)
if ($end -lt 1) { Fail 'SKILL.md frontmatter is not closed with ---.' }
$front = $lines[1..($end - 1)]
if (-not ($front -match '^name: dora-assessment$')) { Fail 'SKILL.md frontmatter needs name: dora-assessment.' }
$descLine = $front | Where-Object { $_ -like 'description: *' } | Select-Object -First 1
if (-not $descLine) { Fail 'SKILL.md frontmatter has no description.' }
$desc = $descLine.Substring('description: '.Length)
if ($desc.Length -gt 500) { Fail "Skill description is $($desc.Length) characters; the Vibe web app allows 500." }
if ($desc -match ': | #') { Fail 'Skill description contains ": " or " #", which breaks the YAML header. Reword it.' }

# Knowledge Base URL: the Claude connector, the Vibe CLI config and CONNECTORS.md must name
# the same endpoint. If the host ever moves and only some of them are updated, packages that
# disagree with each other would reach clients.
$gptSkill = 'chatgpt/skills/dora-assessment'
$kbFiles = "$plugin/.mcp.json", 'vibe/config.snippet.toml', "$skill/CONNECTORS.md", 'chatgpt/mcp.json', "$gptSkill/CONNECTORS.md"
$kbUrls = foreach ($f in $kbFiles) {
    $m = [regex]::Match((Get-Content -Raw (Join-Path $repo $f)), 'https://[A-Za-z0-9.-]+/dora/mcp')
    if (-not $m.Success) { Fail "$f does not name the Knowledge Base endpoint (https://<host>/dora/mcp)." }
    [pscustomobject]@{ File = $f; Url = $m.Value }
}
if (($kbUrls.Url | Sort-Object -Unique).Count -ne 1) {
    Fail ("The Knowledge Base URL differs between files:`n" +
        (($kbUrls | ForEach-Object { "  $($_.File): $($_.Url)" }) -join "`n") +
        "`nUpdate all of them together, and the Knowledge Base server configuration with them.")
}
$kbUrl = $kbUrls[0].Url

# ChatGPT plugin. It carries its own SKILL.md and CONNECTORS.md (no SharePoint step, no
# header-key route) but shares the pillar references, so the checks cannot diverge. Its
# manifest must agree with the Claude one, and its listing fields must fit OpenAI's limits.
$gpt = Get-Content -Raw (Join-Path $repo 'chatgpt/plugin.json') | ConvertFrom-Json
if ($gpt.version -ne $version) { Fail "chatgpt/plugin.json says $($gpt.version) but $plugin/.claude-plugin/plugin.json says $version." }
if ($gpt.name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$' -or $gpt.name.Length -gt 64) { Fail 'chatgpt/plugin.json name must be lowercase letters, numbers and single hyphens, up to 64 characters.' }
$ui = $gpt.extensions.'com.openai'.interface
if ($ui.displayName.Length -gt 30 -or $ui.shortDescription.Length -gt 30) { Fail 'chatgpt/plugin.json displayName and shortDescription must each be 30 characters or fewer.' }
if ($ui.longDescription.Length -gt 4000) { Fail 'chatgpt/plugin.json longDescription is over 4000 characters.' }
$gptMcp = Get-Content -Raw (Join-Path $repo 'chatgpt/mcp.json') | ConvertFrom-Json
$gptServers = @($gptMcp.mcpServers.PSObject.Properties.Name)
if ($gptServers.Count -ne 1 -or $gptServers[0] -ne 'dora-knowledge-base') { Fail 'chatgpt/mcp.json must declare exactly one server, dora-knowledge-base.' }
if ($gptMcp.mcpServers.'dora-knowledge-base'.type -ne 'streamable-http') { Fail 'chatgpt/mcp.json: dora-knowledge-base needs "type": "streamable-http".' }
$gptLines = Get-Content (Join-Path $repo "$gptSkill/SKILL.md") -Encoding utf8
if (($lines[1..2] -join "`n") -ne ($gptLines[1..2] -join "`n")) {
    Fail "$gptSkill/SKILL.md frontmatter (name and description) differs from $skill/SKILL.md."
}

# --- Packaging --------------------------------------------------------------------------

# Each package: zip-internal path -> repo path. Folders are included whole.
$packages = [ordered]@{
    "dora-plugin-$version-claude.zip" = [ordered]@{
        '.claude-plugin/plugin.json' = "$plugin/.claude-plugin/plugin.json"
        '.mcp.json'                  = "$plugin/.mcp.json"
        'skills/dora-assessment'     = $skill
    }
    "dora-assessment-$version-mistral-web.zip" = [ordered]@{
        'dora-assessment' = $skill
    }
    "dora-assessment-$version-mistral-cli.zip" = [ordered]@{
        $skill                     = $skill
        'vibe/README.md'           = 'vibe/README.md'
        'vibe/config.snippet.toml' = 'vibe/config.snippet.toml'
        'vibe/install.ps1'         = 'vibe/install.ps1'
        'vibe/install.sh'          = 'vibe/install.sh'
        'vibe/hooks'               = 'vibe/hooks'
    }
    "dora-assessment-$version-chatgpt.zip" = [ordered]@{
        'plugin.json'                          = 'chatgpt/plugin.json'
        'mcp.json'                             = 'chatgpt/mcp.json'
        'skills/dora-assessment/SKILL.md'      = "$gptSkill/SKILL.md"
        'skills/dora-assessment/CONNECTORS.md' = "$gptSkill/CONNECTORS.md"
        'skills/dora-assessment/references'    = "$skill/references"
    }
}

# Strings that must never ship, even inside an allowed file.
$forbidden = 'sharepoint\.com', 'servicenow-mcp', 'AIArmadillos', 'test\.einar\.partners', 'ecl_[A-Za-z0-9]{8,}'

Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

# Resolve and scan every package before writing any, so a failed run leaves no partial set.
$resolved = [ordered]@{}
foreach ($zipName in $packages.Keys) {
    # Expand folders into individual files, keeping forward-slash entry names on every OS.
    $entries = [ordered]@{}
    foreach ($pair in $packages[$zipName].GetEnumerator()) {
        $source = Join-Path $repo $pair.Value
        if (Test-Path $source -PathType Container) {
            $root = (Resolve-Path $source).Path
            Get-ChildItem -Recurse -File $root | Sort-Object FullName | ForEach-Object {
                $rel = $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
                $entries["$($pair.Key)/$rel"] = $_.FullName
            }
        } elseif (Test-Path $source -PathType Leaf) {
            $entries[$pair.Key] = (Resolve-Path $source).Path
        } else {
            Fail "Missing $($pair.Value) for $zipName."
        }
    }

    # The ChatGPT package is held to a stricter list: no SharePoint, M365 or SAP wording at
    # all, and no review credentials (OpenAI rejects metadata that carries them).
    $patterns = if ($zipName -like '*-chatgpt.zip') {
        $forbidden + 'sharepoint', 'M365', 'Microsoft 365', 'SAP sales', 'test_credentials', 'reviewer_instructions'
    } else { $forbidden }
    foreach ($file in $entries.Values) {
        $hit = Select-String -Path $file -Pattern $patterns -List
        if ($hit) { Fail "$($hit.Path) contains a forbidden string ('$($hit.Matches[0].Value)'); it must not ship." }
    }
    $resolved[$zipName] = $entries
}

New-Item -ItemType Directory -Force $dist | Out-Null
foreach ($zipName in $resolved.Keys) {
    $entries = $resolved[$zipName]
    $zipPath = Join-Path $dist $zipName
    if (Test-Path $zipPath) { Remove-Item -LiteralPath $zipPath }
    $zip = [IO.Compression.ZipFile]::Open($zipPath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($entry in $entries.GetEnumerator()) {
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $entry.Value, $entry.Key) | Out-Null
        }
    } finally { $zip.Dispose() }
    Write-Host ("{0,-48} {1,3} files" -f $zipName, $entries.Count)
}

Write-Host "`nPackages for version $version (Knowledge Base: $kbUrl) are in $dist"
