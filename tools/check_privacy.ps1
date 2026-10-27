# Pre-publish check: no private data in the site, and a list of what is still pending.
# Usage: powershell -ExecutionPolicy Bypass -File tools\check_privacy.ps1
# Patterns live in tools\private_patterns.txt (one regex per line, case-insensitive, # for comments).
# That file is gitignored: it holds the very data it looks for.
$root = Split-Path $PSScriptRoot -Parent
$patternsFile = Join-Path $PSScriptRoot "private_patterns.txt"
if (-not (Test-Path $patternsFile)) { Write-Host "Missing $patternsFile"; exit 2 }
$patterns = Get-Content $patternsFile -Encoding UTF8 | Where-Object { $_.Trim() -and -not $_.StartsWith("#") }

# Only what git would publish: tracked files plus new files that are not ignored.
$published = git -C $root ls-files --cached --others --exclude-standard
if ($LASTEXITCODE -ne 0) { Write-Host "git ls-files failed: run this inside the repo"; exit 2 }
$files = $published | Where-Object { $_ -match '\.(html|css|js|md|svg|txt|xml|json|ps1)$' -and $_ -ne "assets/fonts/OFL.txt" } |
    ForEach-Object { Get-Item (Join-Path $root $_) }

$hits = 0
foreach ($f in $files) {
    $text = Get-Content $f.FullName -Raw -Encoding UTF8
    foreach ($p in $patterns) {
        foreach ($m in [regex]::Matches($text, $p, "IgnoreCase")) {
            $line = ($text.Substring(0, $m.Index) -split "`n").Count
            Write-Host ("PRIVATE  {0}:{1}  matches '{2}'" -f $f.FullName.Substring($root.Length + 1), $line, $p)
            $hits++
        }
    }
}

$todo = $files | Select-String -Pattern "TODO\(Juan\)" -Encoding UTF8
foreach ($t in $todo) { Write-Host ("PENDING  {0}:{1}  {2}" -f $t.Path.Substring($root.Length + 1), $t.LineNumber, $t.Line.Trim()) }

Write-Host ""
Write-Host "$($files.Count) files checked, $hits private matches, $($todo.Count) pending items."
if ($hits) { exit 1 }
