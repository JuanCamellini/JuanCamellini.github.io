# Checks that every internal href/src in the HTML points to a file that exists (and that #anchors exist).
# External links are only listed. Usage: powershell -ExecutionPolicy Bypass -File tools\check_links.ps1
$root = Split-Path $PSScriptRoot -Parent
$broken = 0
$external = @{}

$htmlFiles = Get-ChildItem $root -Recurse -File -Filter *.html | Where-Object { $_.FullName -notmatch '\\(\.git|\.preview)\\' }
foreach ($f in $htmlFiles) {
    $text = Get-Content $f.FullName -Raw -Encoding UTF8
    foreach ($m in [regex]::Matches($text, '(?:href|src|poster)="([^"]+)"')) {
        $link = $m.Groups[1].Value
        if ($link -match '^(https?:|mailto:)') { $external[$link] = $true; continue }
        $path, $anchor = $link.Split("#", 2)
        if ($link.StartsWith("/")) { $target = Join-Path $root $path.TrimStart("/") }   # 404.html uses root paths
        elseif ($path) { $target = Join-Path $f.DirectoryName $path }
        else { $target = $f.FullName }
        if ((Test-Path $target -PathType Container)) { $target = Join-Path $target "index.html" }
        $rel = $f.FullName.Substring($root.Length + 1)
        if (-not (Test-Path $target)) { Write-Host "BROKEN  $rel -> $link"; $broken++; continue }
        if ($anchor) {
            $targetText = Get-Content $target -Raw -Encoding UTF8
            if ($targetText -notmatch ('id="' + [regex]::Escape($anchor) + '"')) { Write-Host "ANCHOR  $rel -> $link"; $broken++ }
        }
    }
}
Write-Host ""
Write-Host "External links (not fetched):"
$external.Keys | Sort-Object | ForEach-Object { Write-Host "  $_" }
Write-Host ""
Write-Host "$($htmlFiles.Count) pages, $broken broken internal links."
if ($broken) { exit 1 }
