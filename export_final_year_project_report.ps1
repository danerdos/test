$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $projectRoot 'final_year_project_report_bilingual.html'
$pdfPath = Join-Path $projectRoot 'Final_Year_Project_Report_Bilingual.pdf'
$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

if (-not (Test-Path $htmlPath)) {
    throw "Report source not found: $htmlPath"
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
