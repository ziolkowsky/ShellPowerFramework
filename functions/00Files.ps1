function Global:Parse-Filename{
    param([string]$f=$Filename)
    if(!$f){ return "{0}-NewScript.ps1" -f $(Get-Date).ToString('yyyyMMdd_HHmmss') }
    if($f -match '.ps1'){ return $f }
    return "{0}.ps1" -f $f
}

function Global:Create-File{
    [Alias('cf')]
    param(
        [switch]$CommentBasedHelp,
        [Parameter(Position=0)]
        [string]$f=$Filename,
        [switch]$Force:Force,
        [Parameter(Position=1)]
        [string[]]$fu=$Functionname
    )
    $f=Parse-Filename $f
    if($fu){
        Create-FileFunction $f $fu -CommentBasedHelp:$CommentBasedHelp
    }else{
        Set-File $f
        Open-File $f
    }
}

function Global:Create-FileFunction{[Alias('cff')]
    param(
        [Parameter(Position=0)]
        [string]$Filename=$Filename,
        [Parameter(Position=1)]
        [string[]]$FunctionName,
        [switch]$CommentBasedHelp
    )
    $fu=$Functionname
    if($fu){
        $f=Parse-Filename $Filename
        $fu | foreach {
            Set-File $f $_ -Append -CommentBasedHelp:$CommentBasedHelp
        }
        Reload-File $f
    }

<#
.SYNOPSIS
Creates funcion in new or existing file.

.DESCRIPTION
Creates function structur in new file or appends it to existing one. You can specify file name, function name
and decide if function should have CommentBased-Help section. 
#>
}

function Global:Remove-File{
    [Alias("rmf")]
    param([string]$f=$Filename) 
        if(!$f){return}
        $f=Parse-Filename $f
        if($f -match $psISE.CurrentFile.DisplayName){
            $psISE.CurrentPowerShellTab.Files.Remove($psISE.CurrentFile) | Out-Null
        }
        rm ".\$f"
        if($f -eq $Global:Filename){rv $Global:Filename -Force:$Force}
        Write-Output $("File {0} has been removed." -f $f)
}

function Global:Open-File{
    [Alias("of")]
    param([Parameter(Position=0)][string]$f) 
        if(!$f){return}
        $f=Parse-Filename $f
        $CheckEditor=Get-Command -CommandType Application | ? { $_.Name -eq 'powershell_ise.exe' -or $_.Source -like '*powershell*ise.exe'}
        if(!$CheckEditor){
            $CheckEditor="notepad.exe"
        }    
        Invoke-Expression "$($CheckEditor.Name) `'$f`'"
        Write-Output $("File {0} has been opened in {1}" -f $f, $CheckEditor.Name.Split('.')[0])
<#
.SYNOPSIS
Opens file in Powershell ISE.

.DESCRIPTION
Opens specified or latest created file. By default it will try to edit file with Powershell ISE  but if not found at system then
it will open in notepad.

.EXAMPLE
PS> Open-File <string>.ps1

.EXAMPLE
PS> of <string>.ps1

.EXAMPLE
PS> of
Open latest created file.
#>
}

function Global:Reload-File{
    [Alias('rl')]
        param([Parameter(Position=0)][string]$f
        )
        $f=Parse-Filename $f
        $itab=$psise.PowerShellTabs.Files | ? { $_.DisplayName -eq $f } 
    
        if(!$itab){
            Open-File $f
            return
        }
        $fp=$itab.FullPath
        $psise.CurrentPowerShellTab.Files.Remove($itab) | Out-Null
        $psise.CurrentPowerShellTab.Files.Add($fp) | Out-Null
        Write-Output "File $f has been reloaded."
}

function Global:Set-File{
    param(
        [Parameter(Position=0)]
        [string]$f,
        [Parameter(Position=1)]
        [string]$fu,
        [switch]$Append,
        [switch]$CommentBasedHelp
        )
    if(!(Test-Path $f) -or ((Test-Path $f) -and $Force)){
        New-Item -ItemType File -Name $f -Path .\ -Force:$Force | Out-Null
        Write-Output "File $f has been created."
    }
    if($Append){
        $s=Get-Function -FunctionName $fu -CommentBasedHelp:$CommentBasedHelp
        $s | Out-File $f -Append
        Write-Output "Function $fu has been added to $f."
    }
}