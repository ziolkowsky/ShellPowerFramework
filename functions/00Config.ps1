$f='.\config_local.txt'
if(!(test-path $f)){
    $f='.\config.txt'
}

$c=(gc $f) -notmatch "^#"

$hc=@{}
$c | foreach {
    $fc=$_ -split "="
    $hc.Add($fc[0].trim(),$fc[1])
}
if(Get-Variable -Scope Global | ? {$_.Name -eq "Config"}){
    Remove-Variable -Name "Config" -Scope Global -Force | Out-Null
}
New-Variable -Name Config -Scope Global -Value $hc