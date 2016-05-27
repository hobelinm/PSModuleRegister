<#
.SYNOPSIS
Registers a PowerShell module in the user's PS Module Path

.DESCRIPTION
Registers a PowerShell module in the user's PS Module path under
$Home\Documents\WindowsPowerShell\Modules by creating a symbolic link
to the actual location of the module manifest

.NOTES 
Requires administrative privileges. It will try to elevate

#>

[CmdletBinding(DefaultParameterSetName = "Path")]
param(
    [Parameter(Mandatory, ParameterSetName = "Path")]
    [ValidateScript({Test-Path ([System.IO.DirectoryInfo] $_)})]
    [string] $Path,
    
    [Parameter(Mandatory, ParameterSetName = "Package")]
    [ValidateNotNullOrEmpty()]
    [string] $Package
)

Write-Host "Hello World: $Path"