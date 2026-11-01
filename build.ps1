# Creates output\document.pdf with all folders in source\ (Windows PowerShell).
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
Set-Location $PSScriptRoot
New-Item -ItemType Directory -Force output | Out-Null

# make text safe for LaTeX: & % $ # _ { } \ ~ ^ are printed as characters
function Escape($s) {
  $s = $s -replace '\\', '\textbackslash '
  $s = $s -replace '([&%$#_{}])', '\$1'
  $s = $s -replace '~', '\textasciitilde '
  $s -replace '\^', '\textasciicircum '
}

# write the content of every folder into output\content.tex
$tex = foreach ($folder in Get-ChildItem source -Directory | Sort-Object Name) {
  $path = "source/$($folder.Name)/"
  $text = Get-ChildItem $folder.FullName -Filter *.txt | Sort-Object Name | Select-Object -First 1

  # every folder starts on a new page
  "\clearpage"
  # text (optional): the whole file, an empty line starts a new paragraph
  if ($text) { Get-Content $text.FullName -Encoding UTF8 | ForEach-Object { Escape $_ } }
  ""
  # images: jpg, jpeg, png, sorted by name
  Get-ChildItem $folder.FullName | Where-Object { $_.Name -match '\.(jpe?g|png)$' } |
    Sort-Object Name | ForEach-Object { "\itemimage{$path$($_.Name)}" }
}
[IO.File]::WriteAllLines("$PSScriptRoot\output\content.tex", [string[]]$tex)

Write-Host "source/ -> output/document.pdf"
xelatex -interaction=nonstopmode -halt-on-error -jobname=document -output-directory=output template.tex | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "  failed, see output/document.log" }

# remove the auxiliary files, keep the PDF and the log
Remove-Item output\*.aux -ErrorAction SilentlyContinue
