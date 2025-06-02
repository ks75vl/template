# template.ps1

param (
    [Parameter(Mandatory = $true)][switch]$Gen,
    [Parameter(Mandatory = $true)][string]$Platform,
    [Parameter(Mandatory = $true)][string]$Type,
    [Parameter(Mandatory = $true)][string]$TargetDir
)

# Validate arguments
# if ($Gen -ne "-Gen") {
#     Write-Host "Invalid argument: -Gen is required" -ForegroundColor Red
#     exit 1
# }

$validPlatforms = @("macos", "linux", "windows")
$validTypes = @("golang", "meson_c", "meson_cpp")
if ($Platform -notin $validPlatforms) {
    Write-Host "Invalid platform. Supported platforms: $validPlatforms" -ForegroundColor Red
    exit 1
}
if ($Type -notin $validTypes) {
    Write-Host "Invalid project type. Supported types: $validTypes" -ForegroundColor Red
    exit 1
}

# Ensure target directory is valid
Write-Host "Checking target directory: $TargetDir" -ForegroundColor Magenta
if (-not (Test-Path $TargetDir)) {
    Write-Host "Creating directory: New-Item -ItemType Directory -Path $TargetDir" -ForegroundColor Green
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}

# Define the public Git repository containing templates
$templateRepo = "https://github.com/ks75vl/template.git"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "project_template_$(Get-Random)"

# Map project type to template folder
$templateMap = @{
    "golang"    = "templates/golang"
    "meson_c"   = "templates/meson_c"
    "meson_cpp" = "templates/meson_cpp"
}

# Clone the specific template
$templatePath = $templateMap[$Type]
Write-Host "Cloning template for $Type from $templateRepo..." -ForegroundColor Magenta
Write-Host "Executing: git clone --no-checkout $templateRepo $tempDir" -ForegroundColor Green
git clone --no-checkout $templateRepo $tempDir
Set-Location $tempDir
Write-Host "Executing: git sparse-checkout set $templatePath" -ForegroundColor Green
git sparse-checkout set $templatePath
Write-Host "Executing: git checkout main" -ForegroundColor Green
git checkout main
Set-Location $templatePath

# Copy template files to target directory
Write-Host "Copying template files to $TargetDir..." -ForegroundColor Magenta
Write-Host "Executing: Copy-Item -Path ./* -Destination $TargetDir -Recurse -Force" -ForegroundColor Green
Copy-Item -Path ./* -Destination $TargetDir -Recurse -Force
Set-Location $PSScriptRoot
Write-Host "Cleaning up temporary directory: $tempDir" -ForegroundColor Magenta
Write-Host "Executing: Remove-Item -Path $tempDir -Recurse -Force" -ForegroundColor Green
Remove-Item -Path $tempDir -Recurse -Force

# Initialize new Git repository in target directory
Set-Location $TargetDir
if (Test-Path .git) {
    Write-Host "Git repository already exists in $TargetDir" -ForegroundColor Magenta
}
else {
    Write-Host "Initializing new Git repository in $TargetDir..." -ForegroundColor Magenta
    Write-Host "Executing: git init" -ForegroundColor Green
    git init
    Write-Host "Executing: git add ." -ForegroundColor Green
    git add .
    Write-Host "Executing: git commit -m 'Initial commit from project initiator'" -ForegroundColor Green
    git commit -m "Initial commit from project initiator"
}

# Platform-specific adjustments (example for Go)
if ($Type -eq "golang") {
    Write-Host "Setting up Go project..." -ForegroundColor Magenta
    Write-Host "Executing: go mod init myproject" -ForegroundColor Green
    go mod init myproject
}

# Open VS Code if installed
if (Get-Command code -ErrorAction SilentlyContinue) {
    Write-Host "Opening VS Code in $TargetDir..." -ForegroundColor Magenta
    Write-Host "Executing: code ." -ForegroundColor Green
    code .
}
else {
    Write-Host "VS Code not found, skipping..." -ForegroundColor Magenta
}

Write-Host "Project initialized successfully in $TargetDir!" -ForegroundColor Magenta