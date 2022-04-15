function Global:Mount-Workdir{
    [Alias('mwd')]
    param([string]$mn=$Global:MountName,[string]$mp=$Global:MountPath)
    if((split-path -leaf $mp) -eq 'functions'){
        $mp=split-path -Parent $mp
    }
    $Mounted=Get-PSDrive | Select Name, Root | where { $_.Name -eq $mn -and $_.Root -eq $mp}
    if($Mounted){
        Write-Host ("Path {0} is alre`dy mounted as {1}`:\" -f $mp, $mn)
        Set-WorkingDirectory
        return
    }
    if(!(Get-PSDrive | where { $_.Name -eq $mn})){
        New-PSDrive -Name $mn -Root $mp -PSProvider FileSystem -Scope Global | Out-Null
        Write-Host "Path $mp has been mounted as $mn`: working directory. OK"
        return
    }
}

function Global:Set-WorkingDirectory{
    [Alias("swd")]
    param([string]$mn=$Global:MountName)
    if($mn -notmatch ':'){
        $mn+=":\"
    }
    if($(pwd).Path -eq $mn){
        return
    }
    Set-Location $mn
    Write-Host "Working directory has been set to $mn"
}

function Global:Unmount-WorkingDirectory{
    [Alias('uwd')]
    param([string]$mn=$Global:MountName)
    if(!$mn){
        return
    }
    Get-PSDrive | Select Name, Root | ? {$_.Name -eq $mn} | foreach{
        Set-WorkingDirectory $_.Root
        Remove-PSDrive -Name $mn -Scope Global -Force
        Write-Host "$mn Working directory has been umounted."
        return
    }
}

function Mount-Init{
    if($Config.'project.name'){
        $Global:MountName=$Config.'project.name'
    }else{
        $Global:MountName=Split-Path (Split-Path -Parent $PSScriptRoot) -Leaf
        
    }
    $Global:MountPath=$PSScriptRoot
    if($Global:Auto){
        Mount-Workdir
        Set-WorkingDirectory
    }
}