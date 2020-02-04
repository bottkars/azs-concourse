$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force

get-item  env:ASDK*
Get-Item WSMan:\localhost\Client\TrustedHosts

set-item WSman:\localhost\Client\TrustedHosts -value $env:ASDK_HOST -Force

Get-Item WSMan:\localhost\Client\TrustedHosts

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
# Enter-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential

Invoke-Command -ComputerName $env:ASDK_HOST -ScriptBlock { Get-ComputerName } -credential $credential

