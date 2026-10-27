# Full-height screenshots of every page with headless Chrome, at desktop and phone widths.
# Usage: powershell -ExecutionPolicy Bypass -File tools\preview.ps1 [-Dark]
# Output: .preview\<page>_<width>.png (gitignored). Nothing is opened on screen.
param([switch]$Dark)
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$root = Split-Path $PSScriptRoot -Parent
$out = Join-Path $root ".preview"
New-Item -ItemType Directory -Force $out | Out-Null

$pages = "index.html", "proyectos/ordenes-retiro.html", "proyectos/facturacion.html",
         "en/index.html", "en/projects/pick-up-orders.html", "en/projects/invoicing.html"
$sizes = @{ 1366 = 6200; 375 = 14000 }
$extra = if ($Dark) { @("--force-dark-mode", "--blink-settings=preferredColorScheme=0") } else { @("--blink-settings=preferredColorScheme=1") }
$suffix = if ($Dark) { "_dark" } else { "" }

foreach ($p in $pages) {
    $file = Join-Path $root $p
    if (-not (Test-Path $file)) { Write-Host "skip $p (missing)"; continue }
    $url = "file:///" + ($file -replace '\\', '/')
    foreach ($w in $sizes.Keys) {
        $png = Join-Path $out (($p -replace '[\\/]', '_' -replace '\.html$', '') + "_$w$suffix.png")
        $target, $window = $url, $w
        if ($w -lt 500) {
            # Chrome on Windows won't make a window narrower than ~500 px: render the phone width inside an iframe
            $frame = Join-Path $out "_frame_$w.html"
            Set-Content $frame -Encoding UTF8 ("<!doctype html><body style='margin:0;background:#888'>" +
                "<iframe src='$url' style='width:${w}px;height:$($sizes[$w])px;border:0;display:block'></iframe>")
            $target, $window = ("file:///" + ($frame -replace '\\', '/')), 500
        }
        $chromeArgs = @("--headless=new", "--disable-gpu", "--hide-scrollbars", "--allow-file-access-from-files") + $extra +
                      @("--window-size=$window,$($sizes[$w])", "--screenshot=$png", $target)
        Start-Process $chrome -ArgumentList $chromeArgs -Wait -WindowStyle Hidden `
            -RedirectStandardError "$out\chrome.log" -RedirectStandardOutput "$out\chrome.out"
        if (Test-Path $png) { Write-Host "ok $png" } else { Write-Host "FAILED $png (see $out\chrome.log)" }
    }
}
