function Global:Parse-FileName{
    param([string]$FileName=$FileName)
    if(!$FileName){ return "{0}-NewScript.ps1" -f $(Get-Date).ToString('yyyyMMdd_HHmmss') }
    if($FileName.Length -ge 5 -and $FileName -match "."){
        if($FileName.Substring($FileName.Length -4,4).Length -eq 4){
            return $FileName
        }
    }
    return "{0}.ps1" -f $FileName
<#
.SYNOPSIS
Parses FileName.

.DESCRIPTION
Parses FileName and returns string with PS1 extension if not provided or whole default string with current datetime in format: yyyyMMdd_HHmmss-NewScript.ps1.
Returns same string when extension was provided with FileName.

.EXAMPLE
PS> Parse-FileName TestFile 

Returns: TestFile.ps1

.EXAMPLE
PS> Parse-FileName 

Returns: 20220415_212359-NewScript.ps1 (based at current Get-Date)

.EXAMPLE 
PS> Parse-FileName TestFile.txt

Returns: TestFile.txt

.PARAMETER f
FileName to parse.

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/parse-filename/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Create-File{
    [Alias('cf')]
    param(
        [switch]$CommentBasedHelp,
        [Parameter(Position=0)]
        [string]$FileName=$FileName,
        [switch]$Force:Force,
        [Parameter(Position=1)]
        [string[]]$FunctionName=$FunctionName
    )
    $FileName=Parse-FileName $FileName
    if($FunctionName){
        Create-FileFunction $FileName $FunctionName -CommentBasedHelp:$CommentBasedHelp
    }else{
        Set-File $FileName
        Open-File $FileName
    }
<#
.SYNOPSIS
Creates and/or opens file.

.DESCRIPTION
Function creates file and opens it. If file already exist it will be opened. If command executes with FunctionName parameter then function structure will be appended to file.
It is possible to attach Comment Based Help section by including proper parameter.

.EXAMPLE
PS> Create-File TestFile 

.EXAMPLE
PS> Create-File TestFile New-Function

.EXAMPLE 
PS> Create-File TestFile New-Function -CommentBasedHelp

.PARAMETER CommentBasedHelp
Adds Comment Based Help to function.

.PARAMETER FileName
File name

.PARAMETER FunctionName
Function name 

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/create-file/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Create-FileFunction{
    [Alias('cff')]
    param(
        [Parameter(Position=0)]
        [string]$FileName=$FileName,
        [Parameter(Position=1)]
        [string[]]$FunctionName,
        [switch]$CommentBasedHelp
    )
    if($FunctionName){
        $FileName=Parse-FileName $FileName
        $FunctionName | foreach {
            Set-File $FileName $_ -Append -CommentBasedHelp:$CommentBasedHelp
        }
        Reload-Tab $FileName
    }

<#
.SYNOPSIS
Creates one or multiple functions in new or existing file.

.DESCRIPTION
Creates functions structure in new file or appends it to existing one. You can specify file name and functions names. 
It is possible to attach Comment Based Help section by including proper parameter.

.PARAMETER CommentBasedHelp
Adds Comment Based Help to functions.

.PARAMETER FileName
File name

.PARAMETER FunctionName
Function name 

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/create-filefunction/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Remove-File{
    [Alias("rmf")]
    param(
        [PSDefaultValue(Help='$psISE.CurrentFile.FullPath')]
        [string]$FileName=($psISE.CurrentFile.FullPath)
    ) 
        if(!$FileName){return}
        $FileName=Parse-FileName $FileName
        if($FileName -match $psISE.CurrentFile.DisplayName){
            $psISE.CurrentPowerShellTab.Files.Remove($psISE.CurrentFile) | Out-Null
        }
        rm ".\$FileName"
        if($FileName -eq $Global:FileName){rv -Name FileName -Scope Global -Force:$Force}
        Write-Output $("File {0} has been removed." -f $FileName)
<#
.SYNOPSIS
Removes file.

.DESCRIPTION
Removes file and closes tab if opened. If FileName not provided then current active file will be removed.

.PARAMETER FileName
File name.

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/remove-file/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Open-File{
    [Alias("of")]
    param([Parameter(Position=0)][string]$FileName) 
        if(!$FileName){return}
        $CheckEditor=Get-Command -CommandType Application | ? { $_.Name -eq 'powershell_ise.exe' -or $_.Source -like '*powershell*ise.exe'}
        if(!$CheckEditor){
            $CheckEditor="notepad.exe"
        }    
        Invoke-Expression "$($CheckEditor.Name) `'$FileName`'"
        Write-Output $("File {0} has been opened in {1}" -f $FileName, $CheckEditor.Name.Split('.')[0])
<#
.SYNOPSIS
Opens file in Powershell ISE.

.DESCRIPTION
Opens specified or latest created file. By default it will try to edit file with Powershell ISE  but if not found at system then it will open in notepad. 
Not sure why it is working this way, just wanted to make it so I did.

.EXAMPLE
PS> Open-File TestFile

.EXAMPLE
PS> Open-File 

Opens latest created file.

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/open-file/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Reload-File{
    [Alias('rl')]
    param(
        [Parameter(Position=0)]
        [string]$File
    )
    $File=Parse-FileName $File
    $itab=$psise.PowerShellTabs.Files | ? { $_.DisplayName -eq $File } 
    if(!$itab){
        Open-File $File
        return
    }
    $fp=$itab.FullPath
    $psise.CurrentPowerShellTab.Files.Remove($itab) | Out-Null
    $psise.CurrentPowerShellTab.Files.Add($fp) | Out-Null
    Write-Output "File $File has been reloaded."
<#
.SYNOPSIS
Opens file in Powershell ISE.

.DESCRIPTION
Opens specified or latest created file. By default it will try to edit file with Powershell ISE  but if not found at system then it will open in notepad. 
Not sure why it is working this way, just wanted to make it so I did.

.EXAMPLE
PS> Reload-File TestFile

.EXAMPLE
PS> Reload-File 

Opens latest created file.

.LINK
https://ziolkowsky.wordpress.com/2022/04/16/reload-file/

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Zió³kowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
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