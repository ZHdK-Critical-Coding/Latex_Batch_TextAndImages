# Creates output\<folder>.pdf for every folder in source\ (Windows PowerShell).
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force output | Out-Null

foreach ($dir in Get-ChildItem source -Directory) {
  $item = $dir.Name
  Write-Host "source/$item -> output/$item.pdf"
  lualatex -interaction=nonstopmode -halt-on-error "-jobname=$item" -output-directory=output template.tex | Out-Null
  if ($LASTEXITCODE -ne 0) { Write-Host "  failed, see output/$item.log" }
}

# remove the auxiliary files, keep the PDFs and logs
Remove-Item output\*.aux -ErrorAction SilentlyContinue
