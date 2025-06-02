# template.ps1

param (
    [Parameter(Mandatory = $true)][switch]$Gen,
    [Parameter(Mandatory = $true)][string]$TemplateName,
    [Parameter(Mandatory = $true)][string]$TargetDir
)

$ErrorActionPreference = 'Stop'

# Ensure target directory is valid
Write-Host "Checking target directory: $TargetDir" -ForegroundColor Cyan
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating directory: New-Item -ItemType Directory -Path $TargetDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# Define the public Git repository containing templates
$templateRepo = "https://github.com/ks75vl/template.git"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "project_template_$(Get-Random)"

# Clone the specific template
Write-Host "Cloning templates from $templateRepo..." -ForegroundColor Cyan
Write-Host "Executing: git clone --no-checkout $templateRepo $tempDir" -ForegroundColor Green
git clone --no-checkout $templateRepo $tempDir
Set-Location $tempDir
Write-Host "Executing: git sparse-checkout set templates/$TemplateName" -ForegroundColor Green
git sparse-checkout set "templates/$TemplateName"
Write-Host "Executing: git checkout main" -ForegroundColor Green
git checkout main

# Check if the template exists
$templatePath = Join-Path $tempDir "templates/$TemplateName"
if (-not (Test-Path $templatePath)) {
    Write-Host "Template '$TemplateName' not found in repository." -ForegroundColor Red
    Write-Host "Executing: Remove-Item -Path $tempDir -Recurse -Force" -ForegroundColor Green
    Set-Location $PSScriptRoot
    Remove-Item -Path $tempDir -Recurse -Force
    exit 1
}
Set-Location $templatePath

# Copy template files to target directory
Write-Host "Copying template files to $TargetDir..." -ForegroundColor Cyan
Write-Host "Executing: Copy-Item -Path ./* -Destination $TargetDir -Recurse -Force" -ForegroundColor Green
Copy-Item -Path ./* -Destination $TargetDir -Recurse -Force
Set-Location $PSScriptRoot
Write-Host "Cleaning up temporary directory: $tempDir" -ForegroundColor Cyan
Write-Host "Executing: Remove-Item -Path $tempDir -Recurse -Force" -ForegroundColor Green
Remove-Item -Path $tempDir -Recurse -Force

# Initialize new Git repository in target directory
Set-Location $TargetDir
if (Test-Path .git) {
    Write-Host "Git repository already exists in $TargetDir" -ForegroundColor Cyan
}
else {
    Write-Host "Initializing new Git repository in $TargetDir..." -ForegroundColor Cyan
    Write-Host "Executing: git init" -ForegroundColor Green
    git init
    Write-Host "Executing: git add ." -ForegroundColor Green
    git add .
    Write-Host "Executing: git commit -m 'Initial commit from project initiator'" -ForegroundColor Green
    git commit -m "Initial commit from project initiator"
}

# Platform-specific adjustments (example for Go)
if ($Type -eq "golang") {
    Write-Host "Setting up Go project..." -ForegroundColor Cyan
    Write-Host "Executing: go mod init myproject" -ForegroundColor Green
    go mod init myproject
}

# Open VS Code if installed
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "Opening VS Code in $TargetDir..." -ForegroundColor Cyan
    Write-Host "Executing: code ." -ForegroundColor Green
    code .
}
else {
    Write-Host "VS Code not found, skipping..." -ForegroundColor Cyan
}

Write-Host "Project initialized successfully in $TargetDir!" -ForegroundColor Cyan