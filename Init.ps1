[CmdletBinding()]
param(
    [switch]$Advanced,
    [switch]$Auto,
    [PsDefaultValue(Help='Function')]
    [ValidateSet('Function','Script','Both')]
    [string]$CodeType='Function', 
    [switch]$CommentBasedHelp,
    [Parameter(Position=0)]
    [string]$File,
    [switch]$Force,
    [Parameter(Position=1)]
    [string[]]$Function
)

$ErrorActionPreference="Stop"
Set-Location $PSScriptRoot

$Global:Advanced=$Advanced
$Global:Auto=$Auto
$Global:CommentBasedHelp=$CommentBasedHelp
$Global:CodeType=$CodeType
$Global:File=$File
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

if($File -and $Function){
    Create-FileFunction $File $Function -CommentBasedHelp:$CommentBasedHelp
}elseif($File){
    $File=Parse-FileName $File
    if(test-path $File){
        of $File
    }else{
        cf $File
    }
}


<#
.DESCRIPTION
Loads framework functions to PS session. 

.SYNOPSIS
Loads framework functions to PS session. 

.EXAMPLE
PS> init.ps1

Loads functions only.

.EXAMPLE
PS> init.ps1 -Auto

Loads functions, mounts and sets working directory.

.EXAMPLE 
PS> .\Init.ps1 TestFile -Auto 

Loads functions, mounts and sets working directory and opens/creates file.

.EXAMPLE 
PS> .\Init.ps1 TestFile New-Function -Auto 

Loads functions, mounts and sets working directory and opens/creates file with function(s).

.EXAMPLE 
PS> .\Init.ps1 TestFile New-Function -Auto -CommentBasedHelp

Loads functions, mounts and sets working directory and opens/creates file with function(s) and comments based help section.

.EXAMPLE 
PS> .\Init.ps1 TestFile New-Func1,New-Func2,New-Func3 -Auto -CommentBasedHelp

.PARAMETER Auto
Some functions can be executed automatically after initial load.

.PARAMETER CommentBasedHelp
Adds comment based help section.

.PARAMETER File
Defines file name.

.Parameter Function
Defines function(s) name(s) which will be append to file.

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/init-ps1/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>