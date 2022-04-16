#start-Process "powershell" -Verb runas -ArgumentList "-noexit Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'" 
#Start-Process "powershell" -Verb runas -ArgumentList "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0; "


Start-Process "powershell" -Verb runas -ArgumentList "-noexit", "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0); #Add-WindowsCapability -Name OpenSSH.Server~~~0.0.1.0 -Online" 

#start-process "powershell" -verb runas -ArgumentList "-noexit get-Service sshd"


# Uninstall the OpenSSH Client
#start-process "powershell" -verb runas -ArgumentList @("-noexit Remove-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0; Remove-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0")

# Uninstall the OpenSSH Server



