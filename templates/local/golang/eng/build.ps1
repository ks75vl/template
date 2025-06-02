param (
    [Parameter(Mandatory = $true)][string]$OutputPath
)

. eng/base/base.ps1

$SourceDir = (Resolve-Path ".").Path

Build-Go -SourceDir $SourceDir -OutputPath $([System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputPath)))