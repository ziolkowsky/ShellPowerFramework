if($Local){$f='.\config_local.txt'}else{$f='.\config.txt'}
$c=$(gc $f -Encoding UTF8) -notmatch "^#"
$hc=@{}
$c | foreach {
    $fc=$_ -split "="
    $hc.Add($fc[0].trim(),$fc[1])
}
if(Get-Variable -Scope Global | ? {$_.Name -eq "Config"}){
    Remove-Variable -Name "Config" -Scope Global -Force | Out-Null
}
New-Variable -Name Config -Scope Global -Value $hc