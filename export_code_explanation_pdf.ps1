$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $projectRoot 'code_explanation_bilingual.html'
$pdfPath = Join-Path $projectRoot 'Code_Explanation_Bilingual.pdf'
$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

if (-not (Test-Path $htmlPath)) {
    throw "Code explanation source not found: $htmlPath"
}

if (-not (Test-Path $edgePath)) {
    throw "Microsoft Edge was not found at: $edgePath"
}

$fileUrl = 'file:///' + ($htmlPath -replace '\\', '/')

& $edgePath `
    --headless `
    --disable-gpu `
    --no-pdf-header-footer `
    --print-to-pdf="$pdfPath" `
    $fileUrl

if (-not (Test-Path $pdfPath)) {
    throw "PDF export failed: $pdfPath"
}

Write-Output "Exported PDF: $pdfPath"
