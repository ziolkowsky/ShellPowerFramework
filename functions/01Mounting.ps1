<#
.SYNOPSIS
Library of functions related with working directory mount actions.

.DESCRIPTION
Library of functions related with working directory mount actions.

.EXAMPLE
PS> .\01Mounting.ps1

Loads functions to current PoweerShell session.

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/01mounting

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>


function Global:Mount-WorkingDirectory{
    [Alias('mwd')]
    param([string]$MountName=$Global:MountName,[string]$Path=$Global:Path)
    if((split-path -leaf $Path) -eq 'functions'){
        $Path=split-path -Parent $Path
    }
    $Mounted=Get-PSDrive | Select Name, Root | where { $_.Name -eq $MountName -and $_.Root -eq $Path}
    if($Mounted){
        Write-Host ("Path {0} is alre`dy mounted as {1}`:\" -f $Path, $MountName)
        Set-WorkingDirectory
        return
    }
    if(!(Get-PSDrive | where { $_.Name -eq $MountName})){
        New-PSDrive -Name $MountName -Root $Path -PSProvider FileSystem -Scope Global | Out-Null
        Write-Host "Path $Path has been mounted as $MountName`: working directory. OK"
        return
    }
<#
.SYNOPSIS
Mounts working directory.

.DESCRIPTION
Mounts working diretory with MountName parameter, projec.name specified in config or config_local file or with frameworks root directory name if both not specified. 
If Path not provided then frameworks root directory will be mounted.

.EXAMPLE
PS> Mount-WorkingDirectory -MountName TestWorkingDirectory -Path .\TestPath

.EXAMPLE
PS> Mount-WorkingDirectory

Mounts frameworks root directory as working directory.

.EXAMPLE 
PS> Mount-WorkingDirectory -MountName TestWorkingDirectory

Mounts frameworkds root directory with TestWorkingDirectory:\ name.

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/mount-workingdirectory

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Set-WorkingDirectory{
    [Alias("swd")]
    param([string]$MountName=$Global:MountName)
    if($MountName -notmatch ':'){
        $MountName+=":\"
    }
    if($(pwd).Path -eq $MountName){
        return
    }
    Set-Location $MountName
    Write-Host "Working directory has been set to $MountName"
<#
.SYNOPSIS
Sets location to mounted working directory.

.DESCRIPTION
Sets location to mounted working directory or specified with MountName

.EXAMPLE
PS> Set-WorkingDirectory -MountName TestWorkingDirectory

.EXAMPLE
PS> Set-WorkingDirectory

Sets already mounted working directory.

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/set-workingdirectory

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Global:Unmount-WorkingDirectory{
    [Alias('uwd')]
    param([string]$MountName=$Global:MountName)
    if(!$MountName){
        return
    }
    Get-PSDrive | Select Name, Root | ? {$_.Name -eq $MountName} | foreach{
        Set-WorkingDirectory $_.Root
        Remove-PSDrive -Name $MountName -Scope Global -Force
        Write-Host "$MountName Working directory has been umounted."
        return
    }
<#
.SYNOPSIS
Unmounts working directory.

.DESCRIPTION
Unmounts last mounted working directory or specified with MountName parameter. 

.EXAMPLE
PS> Unmount-WorkingDirectory

.EXAMPLE
PS> Unmount-WorkingDirectory -MountName TestWorkingDirectory

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/unmount-workingdirectory

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

function Mount-Init{
    Mount-WorkingDirectory
    Set-WorkingDirectory
<#
.SYNOPSIS
Mounts and sets working directory.

.DESCRIPTION
Mounts and sets working directory.

.EXAMPLE
PS> Mount-Init

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/mount-init

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>
}

if($Config.'project.name'){
    $Global:MountName=$Config.'project.name'
}else{
    $Global:MountName=Split-Path (Split-Path -Parent $PSScriptRoot) -Leaf       
}
$Global:Path=$PSScriptRoot

