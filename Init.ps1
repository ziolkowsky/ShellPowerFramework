[CmdletBinding()]
param(
    [switch]$Advanced,
    [switch]$Auto,
    [PsDefaultValue(Help='Function')]
    [ValidateSet('Function','Script','Both')]
    [string]$CodeType='Function', 
    [switch]$CommentBasedHelp,
    [Parameter(Position=0)]
    [string]$Filename,
    [switch]$Force,
    [Parameter(Position=1)]
    [string]$Functionname,
    [switch]$Local
)

$ErrorActionPreference="Stop"
Set-Location $PSScriptRoot

$Global:Advanced=$Advanced
$Global:Auto=$Auto
$Global:CommentBasedHelp=$CommentBasedHelp
$Global:CodeType=$CodeType
$Global:Filename=$Filename
$Global:Force=$Force
Write-Host $null

Get-ChildItem .\functions | where {!$_.PSIsContainer} | foreach {
    try{
        Write-Host "Loading $($_.Name) module: " -NoNewline
        . .\functions\$($_.Name)
        write-host "OK"
    }catch{
        write-host "FAIL"
        throw $_
    }
}
if($Auto){
    Write-Host $null
    Mount-Init
    # Create-Init $Filename $Functionname
}

<#
.DESCRIPTION
Initial loads framework functions to PS session. 

.SYNOPSIS
Loads all framework functions to current Powershell session. When you use -Auto parameter then some of functions will run atuomatically:
- mount script dirrectory
- set it as working directory
- loads global functions

.EXAMPLE
PS> init.ps1

.EXAMPLE
PS> init.ps1 -Auto

.EXAMPLE 
PS> init.ps1 -Auto -Verbose

.EXAMPLE 
PS> .\Init.ps1 -Auto -Filename test -CodeType Function -CommentBasedHelp

.PARAMETER Auto
Some functions can be executed automatically after initial load.

.PARAMETER CommentBasedHelp
Adds Comment-Based Help sections to script and function.

.PARAMETER Local
Defines local config file.

.LINK 
Framework: https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com.\I
GitHub : github.com/ziolkowsky
#>