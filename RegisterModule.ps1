<#
.SYNOPSIS
Registers a PowerShell module in the user's PS Module Path

.DESCRIPTION
Registers a PowerShell module in the user's PS Module path under
$Home\Documents\WindowsPowerShell\Modules by creating a symbolic link
to the actual location of the module manifest. Symbolic link name is 
the name of the module manifest file found in the module's path to
make it discoverable for PowerShell.

.NOTES 
Requires administrative privileges. It will try to elevate if current process
is not running with administrative privileges.
Additionally this script attempts to enable symbolic link evaluation for PowerShell
to be able to follow through the symbolic links into the actual module location.

#>

[CmdletBinding(DefaultParameterSetName = "Path")]
param(
    [Parameter(Mandatory, ParameterSetName = "Path")]
    [ValidateScript({Test-Path ([System.IO.DirectoryInfo] $_)})]
    [string] $Path = "",
    
    [Parameter(Mandatory, ParameterSetName = "Package")]
    [ValidateNotNullOrEmpty()]
    [string] $Package = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Assemble the path of the globally installed package
if ($Package -ne "") {
    $packagePath = Join-Path -Path $env:APPDATA -ChildPath "npm\node_modules\$Package"
    if (-not (Test-Path -Path $packagePath)) {
        Write-Error "Package path not found: $packagePath"
    }
    
    $Path = $packagePath
}

# Test for admin rights
$userPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $userPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Not admin, attempt to elevate
    Write-Warning "Process must run with administrative privileges. Attempting to elevate."
    $powerShellArgs = Join-Path -Path $PSScriptRoot -ChildPath "RegisterModule.ps1" 
    $powerShellProcess = New-Object -TypeName System.Diagnostics.ProcessStartInfo -ArgumentList "PowerShell"
    $powerShellProcess.Arguments = " -c . '$powerShellArgs' -Path '$Path'"
    $powerShellProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($powerShellProcess)
    if (-not $?) {
        Write-Warning "This script requires administrative privileges. To complete retry using administrative privileges."
        Write-Error $_
    }
    
    return
}

# Evaluate symbolic link evaluation
$disabledSymLinkEval = fsutil.exe behavior query SymlinkEvaluation | Where-Object { $_ -match "disabled" }
if ($disabledSymLinkEval -ne $null) {
    Write-Warning "Enabling symbolic evaluation"
    fsutil behavior set SymLinkEvaluation L2L:1
    fsutil behavior set SymLinkEvaluation R2R:1
    fsutil behavior set SymLinkEvaluation L2R:1
    fsutil behavior set SymLinkEvaluation R2L:1
}

# Search for module manifest
$moduleManifest = Get-ChildItem -Path $Path -Filter *.psd1 | Select-Object -First 1
if ($moduleManifest -eq $null) {
    Write-Error "Module manifest not found for path $Path"
}

$moduleManifestName = $moduleManifest.BaseName

# Get user's module location
$modulesFolder = [Environment]::GetFolderPath("MyDocuments")
$modulesFolder = Join-Path -Path $modulesFolder -ChildPath "WindowsPowerShell\Modules"
if (-not (Test-Path $modulesFolder)) {
    New-Item $modulesFolder -ItemType Directory
}

# Check if $modulesFolder is registered in PS Module environment variable for the user
$modulePaths = [Environment]::GetEnvironmentVariable("PSModulePath", [System.EnvironmentVariableTarget]::User) -split ';'
$modulesFolderExist = $modulePaths | Where-Object { $_ -like $modulesFolder }
if ($modulesFolderExist -eq $null) {
    Write-Warning "Modules Path not in PSModulePath, adding it [$modulesFolder]"
    # Need to register the path in the user's module path so PowerShell looks in this directory for modules
    $modulePaths += $modulesFolder
    [Environment]::SetEnvironmentVariable("PSModulePath", ($modulePaths -join ';'), [System.EnvironmentVariableTarget]::User)
    Write-Warning "Path added to PSModulePath, you need to restart PowerShell for the changes to take effect"
}

# Create symbolic link
$symbolicLink = Join-Path -Path $modulesFolder -ChildPath $moduleManifestName
cmd.exe /c mklink /D "$symbolicLink" "$Path"
