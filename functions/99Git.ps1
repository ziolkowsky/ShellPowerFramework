<#
.SYNOPSIS
Library of functions related with Git actions.

.DESCRIPTION
Library of functions related with Git actions.

.EXAMPLE
PS> .\99Git.ps1

Loads functions to current PoweerShell session.

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/99Git-ps1

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Author : Sebastian Ziółkowski
Website: ziolkowsky.wordpress.com
GitHub : github.com/ziolkowsky
#>


function Global:Git-AddCommit{
    [CmdletBinding(SupportsShouldProcess=$true,
    HelpURI="https://ziolkowsky.wordpress.com/category/spframework/")]
    [Alias('giac')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [PSDefaultValue(Help='Nooooo... Comment :(')]
        [string]$CommitMessage,
        [Parameter(Mandatory=$false,Position=1)]
        [PSDefaultValue(Help='(split-path $psISE.CurrentFile.FullPath -leaf)')]
        [string]$File=(split-path $psISE.CurrentFile.FullPath -leaf)
    )
    try{
        [string]$UntrackedFile=(git status) -match $File
        if($UntrackedFile){
            $wFileFormat=$(Parse-GitUntrackedFile $UntrackedFile)
            git add $WFileFormat
            git commit -m $CommitMessage
            Write-Output ("{0} commited: {1} ({2})" -f (git log -1 --format=format:"%H"), $($UntrackedFile), $CommitMessage) 
            return
        }
        Write-Output "There are no changes to commit." 
    }catch{
        Write-Warning "Add-Commit ERROR"
        throw $_
    }
<#
.SYNOPSIS
Adds file to the index and records change to the repository.

.DESCRIPTION
Adds file to the index and records change to the repository.

.EXAMPLE
PS> Git-AddCommit "Commit message"

.EXAMPLE
PS> Git-AddCommit "Commit message" TestFile 

.PARAMETER CommitMessage
Commit message with default value if not provided.

.PARAMETER File
File to commit. By default it is current active file tab.

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/git-addcommit

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com
#>

}


function Global:Git-Add{
    [Alias('gia')]
    param(
        [Parameter(Mandatory=$false,Position=0)]
        [string]$File=(split-path $psISE.CurrentFile.FullPath -leaf)
    )
     try{
        [string]$UntrackedFile=(git status) -match $File
        if($UntrackedFile){
            $wFileFormat=(Parse-GitUntrackedFile $UntrackedFile)
            git add $wFileFormat
            Write-Output ("Added {0} to commit stack." -f $wFileFormat)
        }
    }catch{
        Write-Warning ("Cannot add {0} to commit stack" -f $File)
        throw $_
    }
    
<#
.SYNOPSIS
Adds file contents to the index.

.DESCRIPTION
Adds file contents to the index.

.EXAMPLE
PS> Git-Add

Adds current active file to commit stack.

.PARAMETER File
Adds specified file to commit stack.

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com

Generated by ShellPowerFramework 04/16/2022 12:00:00

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/git-add

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework
#>
}


function Global:Parse-GitUntrackedFile{
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$File
    )
    if($File){
        [string]$WFileFormat= $File -split ":   " | select -Last 1 | % { $_ -replace '/','\'}
        while($WFileFormat.StartsWith('	')){
            $WFileFormat=$WFileFormat.Substring(1,$WFileFormat.Length-1)
        }
        return ("`.`\{0}" -f $WFileFormat)
    }
<#
.SYNOPSIS
Parses untracked file path.

.DESCRIPTION
Parses untracked file path.

.EXAMPLE
PS> Parse-GitUntrackedFile TestFile

.PARAMETER File
File name to parse

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com

Generated by ShellPowerFramework 04/16/2022 12:03:12

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/parse-gituntrackedfile

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework
#>
}


function Git-Push{
    [Alias('gip')]
    param()
    try{
        $output=git push | Out-Null
    }catch{
        if($_ -in ('Everything up-to-date','git : Everything up-to-date')){
            write-host $_
            return
        }elseif($_ -like 'To*'){
            write-host $_
            return            
        }else{
            Write-Warning $_
        }
    }

<#
.SYNOPSIS
Updates remote refs along with associated objects.

.DESCRIPTION
Updates remote refs along with associated objects.

.EXAMPLE
PS> Git-Push

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com

Generated by ShellPowerFramework 04/16/2022 12:18:00

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/git-push

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework
#>
}


function Global:Git-Commit{
    [Alias('gic')]
    param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$CommitMessage
    )
    if(!$CommitMessage){
        Write-Warning "Cannot commit without message."
        return 
    }
    git commit -m $CommitMessage
<#
.SYNOPSIS
Records changes to the repository.

.DESCRIPTION
Records changes to the repository.

.EXAMPLE
PS> Git-Commit "Test commit message"

.PARAMETER CommitMessage
Commit message string.

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/git-commit

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework
#>
}

function Global:Git-Status{
    [Alias('gis','gs')]
    param()
    git status
<#
.SYNOPSIS
Shows the working tree status.

.DESCRIPTION
Shows the working tree status.

.EXAMPLE
PS> Git-Status

.EXAMPLE
PS> gis

.EXAMPLE
PS> gs

.NOTES
Name			 : Sebastian Ziółkowski
Github			 : github.com/ziolkowsky
Website			 : ziolkowsky.wordpress.com

.LINK
https://ziolkowsky.wordpress.com/2022/04/17/git-status

.LINK 
https://github.com/ziolkowsky/ShellPowerFramework
#>
}