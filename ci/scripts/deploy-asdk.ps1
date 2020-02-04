$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force

write-host "$($env:ASDK_HOST) $($env:ASDK_PASSWORD)"
Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -value "$($env:ASDK_HOST)"
Get-Item WSMan:\localhost\Client\TrustedHosts

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
Enter-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential
