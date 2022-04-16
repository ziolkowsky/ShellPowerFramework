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
    [string]$FunctionName,
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
Write-Host $null

if($Auto){
    Mount-Init       
}

if($Filename -and $FunctionName){
    Create-FileFunction $Filename $FunctionName -CommentBasedHelp:$CommentBasedHelp
}elseif($Filename){
    $Filename=Parse-Filename $Filename
    if(test-path $Filename){
        of $Filename
    }else{
        cf $Filename
    }
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

Loads functions only.

.EXAMPLE
PS> init.ps1 -Auto

Loads functions, mounting point and set working directory.

.EXAMPLE 
PS> .\Init.ps1 TestFile -Auto 

.PARAMETER Auto
Some functions can be executed automatically after initial load.

.PARAMETER CommentBasedHelp
Adds Comment-Based Help sections to script and function.

.PARAMETER Local
Defines local config file.

.LINK 
Framework: https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>