function Global:Parse-Filename{
    param([string]$f=$Filename)
    if(!$f){ return "{0}-NewScript.ps1" -f $(Get-Date).ToString('yyyyMMdd_HHmmss') }
    if($f.Substring($f.Length -4,4).StartsWith('.')){
        return $f 
    }
    return "{0}.ps1" -f $f
<#
.SYNOPSIS
Parses filename.

.DESCRIPTION
Parses filename and returns string with PS1 extension if not provided or whole default string with current datetime in format: yyyyMMdd_HHmmss-NewScript.ps1.
Returns same string when extension was provided with filename.

.EXAMPLE
PS> Parse-Filename TestFile 

Returns: TestFile.ps1

.EXAMPLE
PS> Parse-Filename 

Returns: 20220415_212359-NewScript.ps1 (based at current Get-Date)

.EXAMPLE 
PS> Parse-Filename TestFile.txt

Returns: TestFile.txt

.PARAMETER f
Filename to parse.

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
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
<#
.SYNOPSIS
Creates and/or opens file.

.DESCRIPTION
Function creates file and opens it. If file already exist it will be opened. If command executes with Functionname parameter then function structure will be appended to file.
It is possible to attach Comment Based Help section by including proper parameter.

.EXAMPLE
PS> Create-File TestFile 

.EXAMPLE
PS> Create-File TestFile New-Function

.EXAMPLE 
PS> Create-File TestFile New-Function -CommentBasedHelp

.PARAMETER CommentBasedHelp
Adds Comment Based Help to function.

.PARAMETER f
File name

.PARAMETER fu
Function name 

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Create-FileFunction{
    [Alias('cff')]
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
        Reload-Tab $f
    }

<#
.SYNOPSIS
Creates one or multiple functions in new or existing file.

.DESCRIPTION
Creates functions structure in new file or appends it to existing one. You can specify file name and functions names. 
It is possible to attach Comment Based Help section by including proper parameter.

.PARAMETER CommentBasedHelp
Adds Comment Based Help to functions.

.PARAMETER f
File name

.PARAMETER fu
Function name 

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
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
        if($f -eq $Global:Filename){rv -Name Filename -Scope Global -Force:$Force}
        Write-Output $("File {0} has been removed." -f $f)
<#
.SYNOPSIS
Removes file

.DESCRIPTION
Removes file by provided file name or last created if blank. If file is opened in Powershell ISE proper tab will be closed before removing. 

.PARAMETER f
File name

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Open-File{
    [Alias("of")]
    param([Parameter(Position=0)][string]$f) 
        if(!$f){return}
        #$f=Parse-Filename $f
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
it will open in notepad. (Not sure why it is working this way, just wanted to make it so I did)

.EXAMPLE
PS> Open-File TestFile

.EXAMPLE
PS> Open-File 

Opens latest created file.

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
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