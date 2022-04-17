function Global:Write-FileLog{
    param(
        [Parameter(Position=1)]
        [PsDefaultValue(Help='Info')]
        [ValidateSet('Info','Error','Warning')]
        [string]$Type='Info',
        [Parameter(Mandatory,Position=0)]
        [string[]]$String,
        [string]$Path
    )
    if($Path -eq '' -or !$Path){
        # set default value if null or not exist
        $Path='.\logs'
    }

    if(!(test-path $Path)){
        # create log directory if not exist
        New-Item $Path -ItemType Directory | Out-Null
    }

    # date will be use as a part of each log file 
    $Date = Get-Date

     # script name will be used as a part of each log file
    $ScriptName=(Split-Path $MyInvocation.InvocationName -Leaf).split('.')[0]

    # set log file path
    $FilePath="$Path\$($Date.ToString('yyyyMMdd'))_$($ScriptName).log"

    # set log string and append it to file
    "$($Date.ToString('yyyy.MM.dd HH:mm:ss'))`t$($Type.ToUpper())`t$String" | Out-File $FilePath -Append

<#
.SYNOPSIS
Saves log strings in a file.

.DESCRIPTION
Function allow to create log string with timestamp at beginning in log files. New log files will be created each day with proper timestamp at beginning of filename. New entries will be append to existing files.

.EXAMPLE
PS> Write-FileLog "This is info log entry test"

.EXAMPLE
PS> Write-FileLog "This is warning log entry test" -Type Warning

.EXAMPLE
PS> Write-FileLog "This is error log entry test" Error

.PARAMETER Type
Specified what kind of entry it is: Info, Error or Warning

.PARAMETER String
Set string which describes log entry:
Generic message, error description etc.

.PARAMETER Path
Defines log files directory

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/write-filelog

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}