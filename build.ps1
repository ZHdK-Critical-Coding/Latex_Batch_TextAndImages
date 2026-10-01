# Creates output\document.pdf with all folders in source\ (Windows PowerShell).
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force output | Out-Null

Write-Host "source/ -> output/document.pdf"
lualatex -interaction=nonstopmode -halt-on-error -jobname=document -output-directory=output template.tex | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "  failed, see output/document.log" }

# remove the auxiliary files, keep the PDF and the log
Remove-Item output\*.aux -ErrorAction SilentlyContinue
