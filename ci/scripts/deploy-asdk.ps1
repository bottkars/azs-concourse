$password = $env:ASDK_PASSWORD | ConvertTo-SecureString -AsPlainText -Force

get-item  env:ASDK*
Get-Item WSMan:\localhost\Client\TrustedHosts

set-item WSman:\localhost\Client\TrustedHosts -value $env:ASDK_HOST -Force

Get-Item WSMan:\localhost\Client\TrustedHosts

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "Azurestack\Azurestackadmin", $password
$Session = New-PSSession -ComputerName $env:ASDK_HOST -Authentication Negotiate -Credential $credential
$Session
Invoke-Command -ComputerName $env:ASDK_HOST -ScriptBlock { Get-ComputerInfo } -credential $credential
Get-ChildItem -Path ./ -Recurse
write-host "Now copying ASDK"
Invoke-Command -ComputerName $env:ASDK_HOST -ScriptBlock { new-item -ItemType Directory -Path e:\1910 -Force  } -Credential  $credential 
Copy-Item ./cloudbuilder/* -Recurse -Destination c:\test -ToSession $Session