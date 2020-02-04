$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force
Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts "$($env:ASDK_HOST)"
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
Enter-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential
